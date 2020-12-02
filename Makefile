include make/include.mk

.PHONY: all
all: install ## Build and deploy infra

##
# BUILD

.PHONY: build-app
build-app:
	$(call make,docker-compose-build DOCKER_BUILD_TARGET=$*)
	$(call make,up)
	$(call make,docker-compose-exec ARGS='rm -Rf /root/.npm /log-buffer/*' SERVICE=logagent)
	$(call make,docker-commit)

##
# CLEAN

.PHONY: clean-app
clean-app: ;

##
# DEPLOY

## Called when application is deployed in prod/preprod
.PHONY: deploy-app
deploy-app: deploy-ping

##
# INSTALL

.PHONY: install
install: base node up ## Install docker $(STACK) services
