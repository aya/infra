##########
# DEPLOY #
##########

.PHONY: deploy-%
deploy-%: docker-login
	$(eval ENV:=$*)
	$(call make,docker-tag docker-tag-latest ENV=$*)
	$(call make,docker-push docker-push-latest ENV=$*)
	$(call make,ansible-pull@$* ANSIBLE_DOCKER_IMAGE_TAG=$(VERSION) ANSIBLE_TAGS=aws SERVER_NAME=$(SERVER_NAME) ENV=$*,../infra)

.PHONY: deploy-assets-install
deploy-assets-install:
	su -s /bin/sh www-data -c "php app/console --no-interaction assets:install --env=prod"
	su -s /bin/sh www-data -c "php app/console --no-interaction assetic:dump --env=prod"

.PHONY: deploy-cache-clear
deploy-cache-clear:
	su -s /bin/sh www-data -c "php app/console --no-interaction cache:clear --env=prod"

.PHONY: deploy-cache-warmup
deploy-cache-warmup:
	su -s /bin/sh www-data -c "php app/console --no-interaction cache:warmup --env=prod"

.PHONY: deploy-composer
deploy-composer:
	su -s /bin/sh www-data -c "composer install --prefer-dist --optimize-autoloader --no-progress --no-interaction --no-dev"

.PHONY: deploy-doctrine-migrations-migrate
deploy-doctrine-migrations-migrate:
	su -s /bin/sh www-data -c "php app/console --no-interaction doctrine:migrations:migrate"

.PHONY: deploy-npm
deploy-npm: deploy-npm-install deploy-npm-run-build

.PHONY: deploy-npm-install
deploy-npm-install:
	npm set progress=false
	npm install -s

.PHONY: deploy-npm-run-build
deploy-npm-run-build:
	npm run build:prod

.PHONY: deploy-ping
deploy-ping: deploy-ping-slack

.PHONY: deploy-ping-slack
deploy-ping-slack:
	curl -X POST --data-urlencode 'payload={"text": "$(DEPLOY_PING_TEXT)"}' $(DEPLOY_SLACK_HOOK) ||:

.PHONY: deploy-supervisorctl-restart-all
deploy-supervisorctl-restart-all:
	supervisorctl restart all

.PHONY: deploy-supervisorctl-start-all
deploy-supervisorctl-start-all:
	supervisorctl start all

.PHONY: deploy-supervisorctl-stop-all
deploy-supervisorctl-stop-all:
	supervisorctl stop all

.PHONY: deploy-yarn
deploy-yarn: deploy-yarn-install

.PHONY: deploy-yarn-build
deploy-yarn-build:
	yarn build:prod

.PHONY: deploy-yarn-install
deploy-yarn-install:
	yarn install
