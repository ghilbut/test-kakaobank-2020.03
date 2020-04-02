################################################################
##
##  AWS S3
##

##--------------------------------------------------------------
##  AWS Security Groups

resource aws_s3_bucket www {
  bucket        = "${local.web_domain}"
  acl           = "private"
  force_destroy = true

  tags = "${merge(
    map(
      "Name",  "${local.api_domain}",
    ),
    local.tags, 
  )}"
}

resource aws_s3_bucket_policy www {
  bucket = aws_s3_bucket.www.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "cloudfront-only",
  "Statement": [
    {
      "Action":   ["s3:ListBucket"],
      "Effect":   "Allow",
      "Resource": ["${aws_s3_bucket.www.arn}"],
      "Principal": {
        "AWS": [
          "${aws_cloudfront_origin_access_identity.www.iam_arn}"
        ]
      }
    },
    {
      "Action":   ["s3:GetObject"],
      "Effect":   "Allow",
      "Resource": ["${aws_s3_bucket.www.arn}/*"],
      "Principal": {
        "AWS": [
          "${aws_cloudfront_origin_access_identity.www.iam_arn}"
        ]
      }
    }
  ]
}
EOF
}



################################################################
##
##  AWS CloudFront
##

##--------------------------------------------------------------
##  AWS Certificate Manager

provider aws {
  alias   = "acm_certificate"
  region  = "us-east-1"
  profile = var.aws_profile
}

resource aws_acm_certificate www {
  provider = aws.acm_certificate

  domain_name       = "${local.web_domain}"
  validation_method = "DNS"

  tags = merge(
    map(
      "Name", "${local.web_domain}",
    ),
    local.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  www_acm_validation_options = aws_acm_certificate.www.domain_validation_options
}

resource aws_route53_record aws_acm_certificate {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = local.www_acm_validation_options.*.resource_record_name[0]
  type    = local.www_acm_validation_options.*.resource_record_type[0]
  ttl     = 5

  records = [
    local.www_acm_validation_options.*.resource_record_value[0],
  ]
}

##--------------------------------------------------------------
##  AWS CloudFront

resource aws_cloudfront_origin_access_identity www {
  comment = "${local.web_domain}"
}

resource aws_cloudfront_distribution www {
  depends_on = [
    aws_route53_record.aws_acm_certificate,
  ]

  origin {
    domain_name = aws_s3_bucket.www.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.www.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.www.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [
    "${local.web_domain}",
  ]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.www.id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0  # 3600
    max_ttl                = 0  # 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["KR"]
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.www.arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.2_2018"
    ssl_support_method             = "sni-only"
  }
}



################################################################
##
##  AWS Route 53
##

resource aws_route53_record cloudfront {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${local.web_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www.domain_name
    zone_id                = aws_cloudfront_distribution.www.hosted_zone_id
    evaluate_target_health = true
  }
} 
