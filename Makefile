include env.mk
include def.mk
include help.mk
include $(filter-out env.mk def.mk $(wildcard def.*.mk) help.mk $(wildcard stack.*.mk),$(wildcard *.mk))
include $(wildcard ../subrepo.mk)

DOCKERS        := $(dir $(wildcard */docker/*/))

##
# INSTALL

.PHONY: all
all: install ## Build and deploy infra

.PHONY: install
install: base node up ## Install docker $(STACK) services

##
# CLEAN

.PHONY: clean
clean: clean-app docker-down clean-env

.PHONY: clean-app
clean-app:

.PHONY: clean-env
clean-env:
	rm -i .env || true
	rm -i stack/*/.env || true
##
# BUILD

.PHONY: build
build: $(DOCKERS)

.PHONY: $(DOCKERS)
$(DOCKERS):
	if [ $(DOCKER) = "true" ]; then \
		docker build -t $(lastword $(subst /, ,$@)) $@; \
	fi
