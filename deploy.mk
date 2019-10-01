##########
# DEPLOY #
##########

HASH ?= $(shell date +%s)

.PHONY: deploy-%
deploy-%: docker-login
	$(eval ENV:=$*)
	$(call make,docker-tag ENV=$*)
	$(call make,docker-push ENV=$*)
	$(call make,ansible-ssh-run-$* APP=$(APP) ENV=$*,../infra)

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
	curl -X POST --data-urlencode 'payload={"text": "app: *$(APP)* branch: *$(BRANCH)* env: *$(ENV)* version: *$(VERSION)* container: *$(CONTAINER)* host: *$(HOST)*"}' https://hooks.slack.com/services/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

.PHONY: deploy-yarn
deploy-yarn: deploy-yarn-install

.PHONY: deploy-yarn-build
deploy-yarn-build:
	yarn build:prod

.PHONY: deploy-yarn-install
deploy-yarn-install:
	yarn install
