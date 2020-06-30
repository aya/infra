##
# BUILD

.PHONY: build@%
build@%: $(if $(filter $(ENV),$(ENV_DEPLOY)),build-app); ## Build deployment application docker images

.PHONY: build-env
build-env: SERVICE ?= $(DOCKER_SERVICE)
build-env: bootstrap
	$(call docker-compose-exec,$(SERVICE),rm -f .env && make .env ENV=$(ENV) && echo BUILD=true >> .env && echo BUILD_DATE='"\'"'$(shell date "+%d/%m/%Y %H:%M:%S %z" 2>/dev/null)'"\'"' >> .env && echo BUILD_STATUS='"\'"'$(shell git status -uno --porcelain 2>/dev/null)'"\'"' >> .env && echo DOCKER=false >> .env && $(foreach var,$(BUILD_APP_VARS),$(if $($(var)),sed -i '/^$(var)=/d' .env && echo $(var)='$($(var))' >> .env &&)) true)

.PHONY: build-rm
build-rm:
	$(call exec,rm -rf build && mkdir -p build)

.PHONY: build-$(SHARED)
build-$(SHARED): SERVICE ?= $(DOCKER_SERVICE)
build-$(SHARED): bootstrap
	$(call docker-compose-exec,$(SERVICE),mkdir -p /$(SHARED) && $(foreach folder,$(SHARED_FOLDERS),rm -rf $(folder) && mkdir -p $(dir $(folder)) && ln -s /$(SHARED)/$(notdir $(folder)) $(folder) &&) true)
