################################################################
##
##  S3
##

##--------------------------------------------------------------
##  Security Group

resource aws_s3_bucket www {
  bucket        = "${local.srv_name}-${terraform.workspace}.${local.domain_name}"
  acl           = "private"
  force_destroy = true

  tags = "${merge(
    map(
      "Name",  local.domain_name,
      "stage", terraform.workspace,
    ),
    local.tags, 
  )}"
}

resource aws_s3_bucket_policy www {
  bucket = aws_s3_bucket.www.id

  policy = <<POLICY
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
POLICY
}



################################################################
##
##  CloudFront
##

##--------------------------------------------------------------
##  Certificate Manager

provider aws {
  alias   = "acm_certificate"
  region  = "us-east-1"
  profile = var.aws_profile
}

resource aws_acm_certificate www {
  provider = aws.acm_certificate

  domain_name       = "${local.srv_name}.${local.domain_name}"
  validation_method = "DNS"

  tags = merge(
    map(
      "Name", "${local.srv_name}.${local.domain_name}",
    ),
    local.tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_route53_record aws_acm_certificate {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = aws_acm_certificate.www.domain_validation_options.*.resource_record_name[0]
  type    = aws_acm_certificate.www.domain_validation_options.*.resource_record_type[0]
  ttl     = 5

  records = [
    aws_acm_certificate.www.domain_validation_options.*.resource_record_value[0],
  ]
}

##--------------------------------------------------------------
##  CloudFront

resource aws_cloudfront_origin_access_identity www {
  comment = "${local.srv_name}-${terraform.workspace}"
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
    "${local.srv_name}.${local.domain_name}",
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

    viewer_protocol_policy = "allow-all"
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
##  Route 53
##

resource aws_route53_record cloudfront {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${local.srv_name}.${local.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www.domain_name
    zone_id                = aws_cloudfront_distribution.www.hosted_zone_id
    evaluate_target_health = true
  }
} 
