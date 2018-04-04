# Load .env
include env.mk
SUBREPO        := $(notdir $(CURDIR))
CONTEXT        += SUBREPO
include help.mk

DOCKERS        := $(dir $(wildcard docker/*/))
.PHONY: help packer $(DOCKERS)

##
# SUBREPO

-include ../subrepo.mk

bootstrap-git:
	if ! git config remote.subrepo/$(SUBREPO).url > /dev/null ; \
		then git remote add subrepo/$(SUBREPO) $(REMOTE); \
	fi

##
# INSTALL

all: docker-build $(ENV) ## Build and deploy infra

install: $(ENV) ## Install $(ENV) infra

local: stack-services

dev: stack-dev stack-services

##
# DOCKER

docker-build: $(DOCKERS) ## Build docker images

$(DOCKERS):
	if [ $(DOCKER) = "true" ]; then \
		docker build -t $(lastword $(subst /, ,$@)) $@; \
	fi

##
# STACK

stack-dev: ## Start dev stack
	$(MAKE) -C stack/dev install

stack-services: ## Start docker services
	$(MAKE) -C stack/services install

##
# PACKER

packer: ## Build iso images
	$(MAKE) --directory=$@ all

