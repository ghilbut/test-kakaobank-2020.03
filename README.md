# Seoul Public Parking Lots Service
서울열린데이터 광장의 [**서울시 공영주차장 안내 정보**](http://data.seoul.go.kr/dataList/OA-13122/S/1/datasetView.do)를 활용해서 주차 가능한 주차장을 찾을 수 있는 서비스 구현

- 서비스 URL: https://spps.ghilbut.net
- API URL: https://spps-api.ghilbut.net/parking_lots/
- API 문서
  - https://spps-api.ghilbut.net/swagger/
  - https://spps-api.ghilbut.net/redoc/


## A. Local Environment

```bash
$ git clone https://github.com/ghilbut/seoul-public-parking-lot-service.git
```


### A1. Django

#### 개발환경

```bash
# WORKSPACE: ${repodir}/django

# run MySQL with docker-compose on background
$ mkdir -p db/mysql/init
$ tee db/mysql/init.sql << EOF
GRANT ALL PRIVILEGES ON test_spps.* TO 'spps'@'%';
EOF
$ docker-compose up -d

# initialize pipenv environment
$ pipenv install --dev
$ tee .env << EOF
OPEN_API_KEY=********  #서울시 OpenAPI 인증키
EOF

# initialize database
$ pipenv run ./src/manage.py makemigrations
$ pipenv run ./src/manage.py migrate

# create superuser name and password
$ pipenv run ./src/manage.py createsuperuser

# run unit test
$ pipenv run ./src/manage.py test

# run local development server
$ pipenv run ./src/manage.py runserver 0:8000
```

#### 공영주차장 데이터 수집

```bash
# WORKSPACE: ${repodir}/django

# create or update data
$ pipenv run ./src/manage.py crawling
```

#### 결과페이지

- REST API:
  - http://localhost:8000/parking_lots/
  - http://localhost:8000/parking_lots/{code:int}/
- Admin Page: http://localhost:8000/admin
- Documents:
  - Swagger UI: http://localhost:8000/swagger/
  - Swagger Json: http://localhost:8000/swagger.json
  - Swagger Yaml: http://localhost:8000/swagger.yaml
  - Redoc: http://localhost:8000/redoc/


### A2. Vue.js

#### 개발환경

```bash
# WORKSPACE: ${repodir}/vue.js

$ yarn install
$ yarn serve
```

#### 결과페이지

http://localhost:8080/


## B. Production Environment


### B1. Terraform

#### AWS IAM User 생성

[Step1] Add User

- User name: spps
- Access type: [x] Programmatic access / [ ] AWS Management Console access

[Step2] Add tags

- Name: spps
- owner: devops
- purpose: terraform user for production stage

[Step3] Save secrets

- Access key ID
- Secret access key

[Step4] Add inline policy

- Policy name: all
- Policy value:
  ```json
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": "*",
              "Resource": "*"
          }
      ]
  }
  ```

[Step5] Register credentials

```bash
$ vi ~/.aws/credentials
...

[spps]
aws_access_key_id=********
aws_secret_access_key=********
```

#### Terraform 상태 저장소 생성 (AWS S3 Bucket)

[Step1] 기본 설정으로 Bucket 생성

- Name: seoul-public-parking-lot-service-terraform-state
- Region: Asia Pacific (Seoul) ap-northeast-2

[Step2] 태그 설정

- Name: seoul-public-parking-lot-service-terraform-state
- owner: devops
- purpose: terraform state repository


#### Terraform 적용

```bash
# WORKSPACE: ${repodir}/terraform

# initialize
$ terraform init

# environment variables
#   TF_VAR_aws_region  (default: ap-northeast-2)
#   TF_VAR_aws_profile (default: spps)
#   TF_VAR_srv_name    (default: spps)
#   TF_VAR_domain_name (default: ghilbut.net)
$ terraform apply
```

#### (환경삭제)

```bash
# WORKSPACE: ${repodir}/terraform

$ terraform destroy
```


### B2. Django


### B3. Vue.js


#### 수동설치

```bash
# WORKSPACE: ${repodir}/vue.js

$ yarn install
$ yarn build --force
$ aws --profile spps s3 sync --acl public-read ./dist s3://spps.ghilbut.net
```

#### 결과페이지

https://spps.ghilbut.net/
