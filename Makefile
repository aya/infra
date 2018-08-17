include env.mk
include def.mk
include help.mk
include $(filter-out env.mk def.mk help.mk,$(wildcard *.mk))
-include ../subrepo.mk

DOCKERS        := $(dir $(wildcard */docker/*/))

.PHONY: help stack-% $(DOCKERS)
.SILENT:

##
# INSTALL

all: bootstrap build up ## Build and deploy infra

install: bootstrap up ## Install docker $(STACK) services

##
# CLEAN

clean: clean-app docker-down clean-env

clean-app:

clean-env:
	rm -i .env || true
	rm -i stack/*/.env || true

##
# BUILD

build: $(DOCKERS)

$(DOCKERS):
	if [ $(DOCKER) = "true" ]; then \
		docker build -t $(lastword $(subst /, ,$@)) $@; \
	fi
