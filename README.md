# Seoul Public Parking-lot Service
서울열린데이터 광장의 ‘서울시 공영주차장 안내 정보'를 활용해서 주차 가능한 주차장을 찾을 수 있는 서비스 구현


## Local Environment

```bash
$ git clone https://github.com/ghilbut/seoul-public-parking-lot-service.git
```


### Django

```bash
# WORKSPACE: ${repodir}/django

# run MySQL with docker-compose on background
$ mkdir -p db/mysql/init
$ tee db/mysql/init.sql << EOF
GRANT ALL PRIVILEGES ON test_spps.* TO 'spps'@'%';
EOF
$ docker-compose up -d

# install packages
$ pipenv install

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

Check on http://localhost:8000  
Login as superuser on http://localhost:8000/admin

### Vue.js


## Production Environment


### Terraform


### Django


### Vue.js
