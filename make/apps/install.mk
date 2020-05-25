##
# INSTALL

.PHONY: install-mysql-database-%
install-mysql-database-%: infra-base
	$(call exec,mysql -h mysql -u root -proot $* -e "use $*" >/dev/null 2>&1 || mysql -h mysql -u root -proot mysql -e "create database $* character set utf8 collate utf8_unicode_ci;")
	$(call exec,mysql -h mysql -u $* -p$* $* -e "use $*" >/dev/null 2>&1 || mysql -h mysql -u root -proot mysql -e "grant all privileges on $*.* to '\''$*'\''@'\''%'\'' identified by '\''$*'\''; flush privileges;")
	$(call exec,[ $$(mysql -h mysql -u $* -p$* $* -e "show tables" 2>/dev/null |wc -l) -eq 0 ] && [ -f "${APP_DIR}/$*.mysql.gz" ] && gzip -cd "${APP_DIR}/$*.mysql.gz" |mysql -h mysql -u root -proot $* || true)

.PHONY: install-pgsql-database-%
install-pgsql-database-%: infra-base
	$(call exec,PGPASSWORD=$* psql -h postgres -U $* template1 -c "\q" >/dev/null 2>&1 || PGPASSWORD=postgres psql -h postgres -U postgres -c "create user $* with createdb password '\''$*'\'';")
	$(call exec,PGPASSWORD=$* psql -h postgres -U $* -d $* -c "" >/dev/null 2>&1 || PGPASSWORD=postgres psql -h postgres -U postgres -c "create database $* owner $* ;")
	$(call exec,[ $$(PGPASSWORD=$* psql -h postgres -U $* -d $* -c "\d" 2>/dev/null |wc -l) -eq 0 ] && [ -f "${APP_DIR}/$*.pgsql.gz" ] && gzip -cd "${APP_DIR}/$*.pgsql.gz" |PGPASSWORD="postgres" psql -h postgres -U postgres -d $* || true)
	$(call exec,[ $$(PGPASSWORD=$* psql -h postgres -U $* -d $* -c "\d" 2>/dev/null |wc -l) -eq 0 ] && [ -f "${APP_DIR}/$*.pgsql" ] && PGPASSWORD="postgres" psql -h postgres -U postgres -c "ALTER ROLE $* WITH SUPERUSER" && PGPASSWORD="postgres" pg_restore -h postgres --no-owner --role=$* -U postgres -d $* ${APP_DIR}/$*.pgsql && PGPASSWORD="postgres" psql -h postgres -U postgres -c "ALTER ROLE $* WITH NOSUPERUSER" || true)

.PHONY: install-env
install-env: SERVICE ?= $(DOCKER_SERVICE)
install-env: bootstrap
	$(call docker-compose-exec,$(SERVICE),rm -f .env && make .env ENV=$(ENV) && echo BUILD_DATE='"\'"'$(shell date "+%d/%m/%Y %H:%M:%S %z" 2>/dev/null)'"\'"' >> .env && echo BUILD_STATUS='"\'"'$(shell git status -uno --porcelain 2>/dev/null)'"\'"' >> .env && echo DOCKER=false >> .env && $(foreach var,$(BUILD_APP_VARS),$(if $($(var)),sed -i '/^$(var)=/d' .env && echo $(var)='$($(var))' >> .env &&)) true)

.PHONY: install-infra
install-infra: infra-install

.PHONY: install-parameters
install-parameters:
	$(call install-parameters)

.PHONY: install-parameters-%
install-parameters-%:
	$(call install-parameters,$*)

.PHONY: install-$(SHARED)
install-$(SHARED): SERVICE ?= $(DOCKER_SERVICE)
install-$(SHARED): bootstrap
	$(call docker-compose-exec,$(SERVICE),mkdir -p $(SHARED) && $(foreach folder,$(SHARED_FOLDERS),rm -rf $(folder) && ln -s $(call ln_relative_path,$(folder),../)$(SHARED)/$(notdir $(folder)) $(folder) &&) true)

## ln_relative_path = return ../ repeatedly to get relative path of $(1) for ln
# if $(1) is a/sub/directory, relative_path will return ../../ to use it with ln
ln_relative_path = $(if $(findstring /,$(1)),$(subst $(space),,$(foreach folder,$(subst /, ,$(call pop,$(1))),$(2))))
