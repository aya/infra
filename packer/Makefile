include ../env.mk
PACKER_ENV=
PACKER_BUILD_ARGS=-on-error=cleanup -force
ifeq ($(DEBUG), true)
	PACKER_BUILD_ARGS+= -debug
endif
ifeq ($(ENV), dev)
	PACKER_ENV=PACKER_LOG=1 PACKER_KEY_INTERVAL=10ms
endif
ifeq ($(DOCKER), true)
	PACKER_ENV:=$(patsubst %,-e %,$(PACKER_ENV))
endif

CMDS := packer
include ../def.mk
include ../help.mk

TEMPLATES:=$(wildcard */*.json)

.PHONY: help packer $(TEMPLATES)

all: build

packer:
	$(call packer,$(ARGS))

docker-build: ## Build docker image
	$(MAKE) --directory=.. docker-build DOCKERS=docker/packer

build: docker-build $(TEMPLATES) ## Build iso images

$(TEMPLATES):
	$(call packer, build $(PACKER_BUILD_ARGS) $@)

