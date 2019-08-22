include env.mk
include def.mk
include help.mk
include $(filter-out env.mk def.mk $(wildcard def.*.mk) help.mk $(wildcard stack.*.mk),$(wildcard *.mk))
include $(wildcard ../subrepo.mk)

##
# INSTALL

.PHONY: all
all: install ## Build and deploy infra

.PHONY: install
install: base node up ## Install docker $(STACK) services

##
# CLEAN

.PHONY: clean
clean: clean-app docker-compose-down clean-env

.PHONY: clean-%
clean-%:
	$(call make,docker-compose-down DOCKER_COMPOSE_DOWN_OPTIONS="--rmi all -v" ENV=$*)

.PHONY: clean-app
clean-app:

.PHONY: clean-env
clean-env:
	rm -i .env || true
	rm -i stack/*/.env || true
