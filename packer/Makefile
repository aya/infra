include ../env.mk
PACKER_ENV=PACKER_KEY_INTERVAL=10ms
PACKER_BUILD_ARGS=-on-error=cleanup
ifeq ($(DEBUG), true)
	PACKER_BUILD_ARGS+= -debug
endif
ifeq ($(FORCE), true)
	PACKER_BUILD_ARGS+= -force
endif
ifeq ($(_ENV), dev)
	PACKER_ENV+= PACKER_LOG=1
	PACKER_BUILD_ARGS+= -var vnc_port_max=5900
endif
ifeq ($(DOCKER), true)
	PACKER_ENV:=$(patsubst %,-e %,$(PACKER_ENV))
endif

CMDS := packer
include ../def.mk
include ../help.mk

TEMPLATES:=$(wildcard */*.json)

.PHONY: help packer $(TEMPLATES)

all: build-iso

packer:
	$(call packer,$(ARGS))

build: ## Build docker image
	$(MAKE) --directory=.. build DOCKERS=packer/docker/packer

build-iso: build $(TEMPLATES) ## Build iso images

$(TEMPLATES):
	$(call packer, build $(PACKER_BUILD_ARGS) $@)

vnc-forward:
	socat TCP-LISTEN:5900,reuseaddr,fork 'EXEC:docker exec -i infra_packer "socat STDIO TCP-CONNECT:localhost:5900"'

