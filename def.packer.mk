ENV_SYSTEM                      += PACKER_CACHE_DIR=cache PACKER_KEY_INTERVAL=10ms PACKER_LOG=1
KVM_GID                         ?= $(shell getent group kvm |awk -F: '{print $$3}')
PACKER_BUILD_ARGS               ?= -on-error=cleanup -var template=$(PACKER_TEMPLATE)
PACKER_VNC_PORT                 ?= 5900
PACKER_VNC_ADDRESS              ?= 0.0.0.0
ifeq ($(DEBUG), true)
PACKER_BUILD_ARGS               += -debug
endif
ifeq ($(FORCE), true)
PACKER_BUILD_ARGS               += -force
endif
ifeq ($(ENV), local)
PACKER_BUILD_ARGS               += -var vnc_port_max=$(PACKER_VNC_PORT) -var vnc_bind_address=$(PACKER_VNC_ADDRESS)
endif

PACKER_TEMPLATES                ?= $(wildcard packer/*/*.json)

ifeq ($(DOCKER), true)

define packer
	$(call run,$(DOCKER_SSH_AUTH) $(if $(KVM_GID),--group-add $(KVM_GID)) --device /dev/kvm -v $(HOME):/home/$(USER) -p $(PACKER_VNC_PORT):$(PACKER_VNC_PORT) $(DOCKER_REPO)/packer:$(DOCKER_BUILD_TARGET) $(1))
endef

else

define packer
	$(call run,packer $(1))
endef

endif

define packer-build
    $(eval PACKER_TEMPLATE := $(notdir $(basename $(1))))
	$(call packer,build $(PACKER_BUILD_ARGS) $(1))
endef