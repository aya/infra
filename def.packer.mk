CMDS                            += packer
ENV_SYSTEM                      += PACKER_CACHE_DIR=cache PACKER_KEY_INTERVAL=10ms PACKER_LOG=1
KVM_GID                         ?= $(shell getent group kvm |awk -F: '{print $$3}')
PACKER_BUILD_ARGS               ?= -on-error=cleanup -var template=$(PACKER_TEMPLATE) $(foreach var,arch disk_size id_rsa.pub hostname password release template version,$(if $($(var)),-var $(var)='$($(var))'))
PACKER_VNC_PORT                 ?= $(if $(vnc_port_max),$(vnc_port_max),5900)
PACKER_VNC_ADDRESS              ?= $(if $(vnc_bind_address),$(vnc_bind_address),0.0.0.0)
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
PACKER_ISOS                     ?= $(wildcard iso/*/*.iso)

ifeq ($(DOCKER), true)

define packer
	$(call run,$(DOCKER_SSH_AUTH) $(if $(KVM_GID),--group-add $(KVM_GID)) --device /dev/kvm -v $(HOME):/home/$(USER) -p $(PACKER_VNC_PORT):$(PACKER_VNC_PORT) $(DOCKER_REPO)/packer:$(DOCKER_BUILD_TARGET) $(1))
endef
define packer-qemu
	$(call run,$(if $(KVM_GID),--group-add $(KVM_GID)) --device /dev/kvm -p $(PACKER_VNC_PORT):$(PACKER_VNC_PORT) --entrypoint=qemu-system-x86_64 $(DOCKER_REPO)/packer:$(DOCKER_BUILD_TARGET) -enable-kvm -m 512m -drive file=$(1)$(comma)format=raw -vnc $(PACKER_VNC_ADDRESS):$(subst 590,,$(PACKER_VNC_PORT)))
endef

else

define packer
	$(call run,packer $(1))
endef
define packer-qemu
	$(call run,qemu-system-x86_64 -enable-kvm -m 512m -drive file=$(1)$(comma)format=raw)
endef

endif

define packer-build
    $(eval PACKER_TEMPLATE := $(notdir $(basename $(1))))
	$(call packer,build $(PACKER_BUILD_ARGS) $(1))
endef
