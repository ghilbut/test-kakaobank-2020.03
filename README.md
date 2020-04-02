# Seoul Public Parking-lot Service
서울열린데이터 광장의 [**서울시 공영주차장 안내 정보**](http://data.seoul.go.kr/dataList/OA-13122/S/1/datasetView.do)를 활용해서 주차 가능한 주차장을 찾을 수 있는 서비스 구현



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


#### 결과페이지

- http://localhost:8080/


## B. Production Environment


### B1. Terraform


#### Create AWS IAM User

**[Step1] Add User**

- User name: spps
- Access type: [x] Programmatic access / [ ] AWS Management Console access

**[Step2] Add tags**

- Name: spps
- owner: devops
- purpose: terraform user for production stage

**[Step3] Save secrets**

- Access key ID
- Secret access key

**[Step4] Add inline policy**

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

**[Step5] Register credentials**

```bash
$ vi ~/.aws/credentials
...

[spps]
aws_access_key_id=********
aws_secret_access_key=********
```


#### Create AWS S3 Bucket for terraform state

**[Step1] Create bucket with default options**

- Name: seoul-public-parking-lot-service-terraform-state
- Region: Asia Pacific (Seoul) ap-northeast-2

**[Step2] Set tags

- Name: seoul-public-parking-lot-service-terraform-state
- owner: devops
- purpose: terraform state repository


#### Apply

```bash
# WORKSPACE: ${repodir}/terraform

# initialize
$ terraform init

# environment variables
# - TF_VAR_aws_region  (default: ap-northeast-2)
# - TF_VAR_aws_profile (default: spps)
# - TF_VAR_srv_name    (default: spps)
# - TF_VAR_domain_name (default: ghilbut.net)
$ terraform apply
```


#### Destroy (if you want)

```bash
# WORKSPACE: ${repodir}/terraform

$ terraform destroy
```


### B2. Django


### B3. Vue.js
