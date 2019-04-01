ENV_SYSTEM                      += PACKER_KEY_INTERVAL=10ms
PACKER_BUILD_ARGS               ?= -on-error=cleanup
ifeq ($(DEBUG), true)
PACKER_BUILD_ARGS               += -debug
endif
ifeq ($(FORCE), true)
PACKER_BUILD_ARGS               += -force
endif
ifeq ($(ENV), local)
ENV_SYSTEM                      += PACKER_LOG=1
PACKER_BUILD_ARGS               += -var vnc_port_max=5900
endif

PACKER_TEMPLATES:=$(wildcard packer/*/*.json)

.PHONY: packer
packer:
	$(call packer,$(ARGS))

.PHONY: packer-build-iso
packer-build-images: $(PACKER_TEMPLATES) ## Build iso images

.PHONY: $(PACKER_TEMPLATES)
$(PACKER_TEMPLATES): docker-build-packer
	$(call packer, build $(PACKER_BUILD_ARGS) $@)

.PHONY: vnc-forward
vnc-forward:
	socat TCP-LISTEN:5900,reuseaddr,fork 'EXEC:docker exec -i $(COMPOSE_PROJECT_NAME)_packer_1 "socat STDIO TCP-CONNECT:localhost:5900"'
