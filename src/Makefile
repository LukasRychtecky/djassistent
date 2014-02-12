#
# Run install_packages as root. 
# Then run local_install from current directory (for local install + app build).
#

SHELL = bash

DJANGO_DIR = dj
VIRTUAL_ENV = var/ve
LOCALPATH ?= $(CURDIR)
CONFIG_PATH ?= $(LOCALPATH)/build
DJASSISTENT_PATH ?= $(CONFIG_PATH)/djassistent
PYTHONPATH = $(LOCALPATH)/$(DJANGO_DIR)
SETTINGS = dev.sqlite
DJANGO_TEST_PORT = 8082
DJANGO_SETTINGS_MODULE = $(DJANGO_DIR).settings.$(SETTINGS)
DJANGO_POSTFIX = --settings=$(DJANGO_SETTINGS_MODULE) --pythonpath=$(PYTHONPATH)
PYTHON_BIN = $(VIRTUAL_ENV)/bin
TYPE = prod
OS = $(shell uname)
TASK_DIR = $(DJASSISTENT_PATH)/tasks

DB_INFO = python -c "from $(DJANGO_SETTINGS_MODULE) import *; print DATABASES.get('default').get('$$val')"
DB_ENGINE = $(shell val='ENGINE';$(DB_INFO))
DB_USER =  $(shell val='USER';$(DB_INFO))
DB_USER_PASSWORD =  $(shell val='PASSWORD';$(DB_INFO))
DB_NAME = $(shell val='NAME';$(DB_INFO))

db_root_user ?= $(shell read -r -p "Postgres root user name: " REPLY;echo $$REPLY;)
db_root_password ?= $(shell read -r -s -p "Postgres root user password: " REPLY;echo $$REPLY;)

-include $(CONFIG_PATH)/default_config
-include $(CONFIG_PATH)/config
include $(DJASSISTENT_PATH)/Makefile.$(OS)
include $(DJASSISTENT_PATH)/Makefile.$(TYPE)

default:
	@echo " 1. checkout repository - git clone url"
	@echo
	@echo "When installing for the first time (or updating packages)"
	@echo " 2. sudo make install_packages - to install deb packages to your system"
	@echo " 3. make install - to install python packages, libraries, JS packages and init database"
	@echo
	@echo "Reset database"
	@echo " 4. make resetdb - to clear database, create again and load init data"
	@echo
	@echo "Build and run locally"
	@echo " 5. make runserver - to run python server and connect to localhost:8000 from browser"

clean:
	# Delete .pyc files and empty directories.
	find . -name "*.pyc" -exec rm -rf {} \;
	find . -type d -empty -delete 2>&1 > /dev/null

cleanvirtualenv:
	rm -rf $(VIRTUAL_ENV)

cleanvar: clean cleanvirtualenv
	rm -rf $(LOCALPATH)/node_modules $(LOCALPATH)/bower_components $(LOCALPATH)/var $(LOCALPATH)/$(DJANGO_DIR)/static/js

cleandb:
ifeq ($(DB_ENGINE),django.db.backends.postgresql_psycopg2)
	@db_root_user=$(db_root_user);db_root_password=$(db_root_password);echo;\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "DROP DATABASE IF EXISTS $(DB_NAME);";\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "DROP DATABASE IF EXISTS test_$(DB_NAME);";\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "DROP USER IF EXISTS $(DB_USER);";
endif

cleanall: cleanvar cleandb

taskvars:
	@$(SHELL) $(TASK_DIR)/bootstrap.sh

checkpip:
	@$(SHELL) $(TASK_DIR)/update-pip.sh

pip:
	$(PYTHON_BIN)/pip install --process-dependency-links --allow-all-external -r requirements.txt

initvirtualenv:
	virtualenv --no-site-packages $(VIRTUAL_ENV)
	$(PYTHON_BIN)/pip install --upgrade pip==1.5
	$(PYTHON_BIN)/pip install setuptools --no-use-wheel --upgrade

installjs:
	npm install
	bower install

jssymlinks:
	mkdir -p $(LOCALPATH)/dj/static/js
	# install packages required by front-end
	ln -sf $(LOCALPATH)/var/cs/deps.js $(LOCALPATH)/bower_components/closure-library/closure/goog\
	 $(LOCALPATH)/var/cs/start.js $(LOCALPATH)/var $(LOCALPATH)/bower_components $(LOCALPATH)/dj/static/js

buildjs:
	# build front-end (compile javascripts, etc)
	grunt build

checkjspkgs:
	@$(SHELL) $(TASK_DIR)/bower-npm.sh

checkjs:
	@$(SHELL) $(TASK_DIR)/build-client.sh

bootstrap: initvirtualenv pip

reinstallvirtualenv: cleanvirtualenv bootstrap initvirtualenv initenv

test: clean
	$(PYTHON_BIN)/coverage run --omit */site-packages/*,*/migrations/*,*/lib/* $(LOCALPATH)/manage.py test\
	 $(test_modules)  --liveserver=localhost:$(DJANGO_TEST_PORT) $(DJANGO_POSTFIX) -v 2

htmlcoverage: test
	$(PYTHON_BIN)/coverage html -d $(LOCALPATH)/var/reports/htmlcov --omit */site-packages/*,*/migrations/*,*/lib/*
	$(OPENHTML) $(LOCALPATH)/var/reports/htmlcov/index.html

initdb:
ifeq ($(DB_ENGINE),django.db.backends.sqlite3)
	mkdir -p $(LOCALPATH)/var/db
endif

ifeq ($(DB_ENGINE),django.db.backends.postgresql_psycopg2)
	@db_root_user=$(db_root_user);db_root_password=$(db_root_password);echo;\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "DROP DATABASE IF EXISTS $(DB_NAME);";\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "DROP USER IF EXISTS $(DB_USER);";\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "DROP DATABASE IF EXISTS test_$(DB_NAME);";\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "CREATE DATABASE $(DB_NAME);";\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "CREATE USER $(DB_USER) WITH PASSWORD '$(DB_USER_PASSWORD)' CREATEDB;";\
	 PGPASSWORD=$$db_root_password psql -U $$db_root_user -d template1 -c "GRANT ALL PRIVILEGES ON DATABASE $(DB_NAME) TO $(DB_USER)";
endif

syncdb:
	$(PYTHON_BIN)/python manage.py syncdb --noinput $(DJANGO_POSTFIX)
	$(PYTHON_BIN)/python manage.py migrate $(DJANGO_POSTFIX)
	if [ -a data/dev/init.json ]; then $(PYTHON_BIN)/python manage.py loaddata data/dev/init.json $(DJANGO_POSTFIX); fi;

migrate:
	$(PYTHON_BIN)/python manage.py migrate $(DJANGO_POSTFIX)

checkdb:
	@$(SHELL) $(TASK_DIR)/db-migrate.sh

resetdb:
ifeq ($(DB_ENGINE),django.db.backends.postgresql_psycopg2)
	$(MAKE) initdb
else
	$(PYTHON_BIN)/python manage.py reset_db --noinput $(DJANGO_POSTFIX)
endif
	$(MAKE) syncdb

initlog:
	mkdir -p $(LOCALPATH)/var/log

initenv:
	echo -e '\nDJANGO_SETTINGS_MODULE="$(DJANGO_SETTINGS_MODULE)"' >> $(VIRTUAL_ENV)/bin/activate
	echo -e 'export DJANGO_SETTINGS_MODULE' >> $(VIRTUAL_ENV)/bin/activate

install: cleanvar bootstrap installjs jssymlinks initlog initdb syncdb buildjs initenv

-include build/extra
