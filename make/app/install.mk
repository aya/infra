##
# INSTALL

.PHONY: install-assets
install-assets: install-assets-$(SYMFONY_ENV)

.PHONY: install-assets-%
install-assets-%: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),app/console assetic:dump --env=$*)
	$(call docker-compose-exec,$(DOCKER_SERVICE),app/console assets:install --env=$*)
	$(if $(filter $(ENV),preprod prod),$(call docker-compose-exec,$(DOCKER_SERVICE),chown -R www-data web/bundles/ web/css/ web/js/))

.PHONY: install-bower
install-bower: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),npm install bower --allow-root)
	$(call docker-compose-exec,$(DOCKER_SERVICE),./node_modules/bower/bin/bower install --allow-root)

.PHONY: install-codecept
install-codecept: bootstrap install-phpunit vendor/codeception/codeception/codecept

vendor/codeception/codeception/codecept:
	$(call composer-require-vendor-binary,codeception/codeception,codecept)

.PHONY: install-composer
install-composer: bootstrap
	$(call composer,install)

.PHONY: install-database-%
install-database-%: bootstrap
	$(call exec,mysql -h mysql -u root -proot $* -e "use $*" >/dev/null 2>&1 || mysql -h mysql -u root -proot mysql -e "create database $* character set utf8 collate utf8_unicode_ci;")
	$(call exec,mysql -h mysql -u $* -p$* $* -e "use $*" >/dev/null 2>&1 || mysql -h mysql -u root -proot mysql -e "grant all privileges on $*.* to '\''$*'\''@'\''%'\'' identified by '\''$*'\''; flush privileges;")
	$(call exec,[ $$(mysql -h mysql -u $* -p$* $* -e "show tables" 2>/dev/null |wc -l) -eq 0 ] && [ -f "${SUBREPO_DIR}/$*.mysql.gz" ] && gzip -cd "${SUBREPO_DIR}/$*.mysql.gz" |mysql -h mysql -u root -proot $* || true)

.PHONY: install-doctrine-schema-update
install-doctrine-schema-update: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),php app/console doctrine:schema:update --force)

.PHONY: install-env
install-env: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -f .env && make .env ENV=$(ENV) && echo BUILD_DATE=$(date "+%d/%m/%Y %H:%M:%S %z") >> .env && echo BUILD_STATUS=$(git status -uno --porcelain |wc -l) >> .env && echo DOCKER=false >> .env && $(foreach var,$(BUILD_APP_VARS),$(if $($(var)),echo $(var)='$($(var))' >> .env &&)) true)

.PHONY: install-npm
install-npm: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),npm install)

.PHONY: install-npm-run-build
install-npm-run-build: install-npm-run-build-$(SYMFONY_ENV)

.PHONY: install-npm-run-build-%
install-npm-run-build-%: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),npm run build:$*)

.PHONY: install-parameters
install-parameters:
	$(call install-parameters)

.PHONY: install-parameters-%
install-parameters-%:
	$(call install-parameters,$*)

.PHONY: install-phpcbf
install-phpcbf: bootstrap vendor/squizlabs/php_codesniffer/bin/phpcbf

vendor/squizlabs/php_codesniffer/bin/phpcbf:
	$(call composer-require-vendor-binary,squizlabs/php_codesniffer,bin/phpcbf)

.PHONY: install-phpcs
install-phpcs: bootstrap vendor/squizlabs/php_codesniffer/bin/phpcs

vendor/squizlabs/php_codesniffer/bin/phpcs:
	$(call composer-require-vendor-binary,squizlabs/php_codesniffer,bin/phpcs)

.PHONY: install-phpunit
install-phpunit: bootstrap vendor/phpunit/phpunit/phpunit

vendor/phpunit/phpunit/phpunit:
	$(call composer-require-vendor-binary,phpunit/phpunit)

.PHONY: install-shared
install-shared: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),mkdir -p /var/www/shared && $(foreach folder,$(SHARED_FOLDERS),rm -rf /var/www/$(folder) && ln -s /var/www/shared/$(notdir $(folder)) /var/www/$(folder) &&) true)

.PHONY: install-yarn
install-yarn: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn install)
