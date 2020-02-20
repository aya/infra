include make/include.mk

.PHONY: all
all: install ## Build and deploy infra

##
# BUILD

.PHONY: build-%
build-%: build-rm
	$(eval ENV:=$*)
	$(call make,docker-compose-build DOCKER_BUILD_TARGET=$* ENV=$*)
	$(call make,up ENV=$*)
	$(call make,docker-compose-exec ARGS='rm -Rf /root/.npm /log-buffer/*' ENV=$* SERVICE=logagent)
	$(call make,docker-commit ENV=$*)

##
# CLEAN

.PHONY: clean
clean: docker-compose-down clean-env clean-stack-env

.PHONY: clean-stack-env
clean-stack-env:
	rm -i stack/*/.env || true

##
# DEPLOY

.PHONY: deploy
deploy: deploy-ping

##
# INSTALL

.PHONY: install
install: base node up ## Install docker $(STACK) services

