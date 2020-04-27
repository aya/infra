##
# INSTALL

.PHONY: install-database-%
install-database-%: bootstrap
	$(call exec,mysql -h mysql -u root -proot $* -e "use $*" >/dev/null 2>&1 || mysql -h mysql -u root -proot mysql -e "create database $* character set utf8 collate utf8_unicode_ci;")
	$(call exec,mysql -h mysql -u $* -p$* $* -e "use $*" >/dev/null 2>&1 || mysql -h mysql -u root -proot mysql -e "grant all privileges on $*.* to '\''$*'\''@'\''%'\'' identified by '\''$*'\''; flush privileges;")
	$(call exec,[ $$(mysql -h mysql -u $* -p$* $* -e "show tables" 2>/dev/null |wc -l) -eq 0 ] && [ -f "${APP_DIR}/$*.mysql.gz" ] && gzip -cd "${APP_DIR}/$*.mysql.gz" |mysql -h mysql -u root -proot $* || true)

.PHONY: install-env
install-env: SERVICE ?= $(DOCKER_SERVICE)
install-env: bootstrap
	$(call docker-compose-exec,$(SERVICE),rm -f .env && make .env ENV=$(ENV) && echo BUILD_DATE='"\'"'$(shell date "+%d/%m/%Y %H:%M:%S %z" 2>/dev/null)'"\'"' >> .env && echo BUILD_STATUS='"\'"'$(shell git status -uno --porcelain 2>/dev/null)'"\'"' >> .env && echo DOCKER=false >> .env && $(foreach var,$(BUILD_APP_VARS),$(if $($(var)),sed -i '/^$(var)=/d' .env && echo $(var)='$($(var))' >> .env &&)) true)

.PHONY: install-shared
install-shared: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),mkdir -p /var/www/shared && $(foreach folder,$(SHARED_FOLDERS),rm -rf /var/www/$(folder) && ln -s /var/www/shared/$(notdir $(folder)) /var/www/$(folder) &&) true)
