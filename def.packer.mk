CMDS                            += packer
ENV_VARS                        += PACKER_CACHE_DIR PACKER_KEY_INTERVAL PACKER_LOG
KVM_GID                         ?= $(call getent-group,kvm)
PACKER_ARCH                     ?= $(PACKER_ALPINE_ARCH)
PACKER_BUILD_ARGS               ?= -on-error=cleanup $(foreach var,$(PACKER_BUILD_VARS),$(if $($(var)),-var $(var)='$($(var))'))
PACKER_BUILD_VARS               += hostname iso_name iso_size output password template username
PACKER_CACHE_DIR                ?= cache
PACKER_HOSTNAME                 ?= $(PACKER_TEMPLATE)
PACKER_ISO_DATE                 ?= $(shell stat -c %y $(PACKER_ISO_FILE) 2>/dev/null)
PACKER_ISO_FILES                ?= $(wildcard iso/*/*.iso)
PACKER_ISO_FILE                  = $(PACKER_OUTPUT)/$(PACKER_ISO_NAME).iso
PACKER_ISO_INFO                  = $(PACKER_OUTPUT)/$(PACKER_ISO_NAME).nfo
PACKER_ISO_NAME                  = $(PACKER_TEMPLATE)-$(PACKER_RELEASE)-$(PACKER_ARCH)
PACKER_ISO_SIZE                 ?= 2048
PACKER_KEY_INTERVAL             ?= 10ms
PACKER_LOG                      ?= 1
PACKER_OUTPUT                   ?= iso/$(ENV)/$(PACKER_TEMPLATE)
PACKER_PASSWORD                 ?= $(PACKER_TEMPLATE)
PACKER_RELEASE                  ?= $(PACKER_ALPINE_RELEASE)
PACKER_SSH_PORT                 ?= $(if $(ssh_port_max),$(ssh_port_max),2222)
PACKER_SSH_ADDRESS              ?= $(if $(ssh_bind_address),$(ssh_bind_address),0.0.0.0)
PACKER_TEMPLATES                ?= $(wildcard packer/*/*.json)
PACKER_TEMPLATE                 ?= alpine
PACKER_USERNAME                 ?= root
PACKER_VNC_PORT                 ?= $(if $(vnc_port_max),$(vnc_port_max),5900)
PACKER_VNC_ADDRESS              ?= $(if $(vnc_bind_address),$(vnc_bind_address),0.0.0.0)
ifeq ($(DEBUG), true)
PACKER_BUILD_ARGS               += -debug
endif
ifeq ($(FORCE), true)
PACKER_BUILD_ARGS               += -force
endif
ifeq ($(ENV), local)
PACKER_BUILD_ARGS               += -var ssh_port_max=$(PACKER_SSH_PORT) -var vnc_port_max=$(PACKER_VNC_PORT) -var vnc_bind_address=$(PACKER_VNC_ADDRESS)
endif

hostname                        ?= $(PACKER_HOSTNAME)
iso_name                        ?= $(PACKER_ISO_NAME)
iso_size                        ?= $(PACKER_ISO_SIZE)
output                          ?= $(PACKER_OUTPUT)
password                        ?= $(PACKER_PASSWORD)
template                        ?= $(PACKER_TEMPLATE)
username                        ?= $(PACKER_USERNAME)

ifneq ($(filter $(ENV),prod preprod),)
ifeq ($(password), $(template))
password                        := $(or $(shell pwgen -csy -r\' 64 1 2>/dev/null),$(shell date +%s | sha256sum | base64 | head -c 64))
endif
endif

ifeq ($(DOCKER), true)

define packer
	$(call run,$(DOCKER_SSH_AUTH) $(if $(KVM_GID),--group-add $(KVM_GID)) --device /dev/kvm -v $(HOME):/home/$(USER) -p $(PACKER_SSH_PORT):$(PACKER_SSH_PORT) -p $(PACKER_VNC_PORT):$(PACKER_VNC_PORT) $(DOCKER_REPO)/packer:local $(1))
endef
define packer-qemu
	echo Running $(1)
	$(call run,$(if $(KVM_GID),--group-add $(KVM_GID)) --device /dev/kvm -p $(PACKER_SSH_PORT):$(PACKER_SSH_PORT) -p $(PACKER_VNC_PORT):$(PACKER_VNC_PORT) --entrypoint=qemu-system-x86_64 $(DOCKER_REPO)/packer:local -enable-kvm -m 512m -drive file=$(1)$(comma)format=raw -net nic$(comma)model=virtio -net user$(comma)hostfwd=tcp:$(PACKER_SSH_ADDRESS):$(PACKER_SSH_PORT)-:22 -vnc $(PACKER_VNC_ADDRESS):$(subst 590,,$(PACKER_VNC_PORT)))
endef

else

define packer
	$(call run,packer $(1))
endef
define packer-qemu
	echo Running $(1)
	$(call run,qemu-system-x86_64 -enable-kvm -m 512m -drive file=$(1)$(comma)format=raw -net nic$(comma)model=virtio -net user$(comma)hostfwd=tcp:$(PACKER_SSH_ADDRESS):$(PACKER_SSH_PORT)-:22 -vnc $(PACKER_VNC_ADDRESS):$(subst 590,,$(PACKER_VNC_PORT)))
endef

endif

define packer-build
	$(eval PACKER_TEMPLATE := $(notdir $(basename $(1))))
	echo Building $(PACKER_ISO_FILE)
	$(call packer,build $(PACKER_BUILD_ARGS) $(1))
	echo 'aws_id: $(ANSIBLE_AWS_ACCESS_KEY_ID)'                  > $(PACKER_ISO_INFO)
	echo 'aws_key: $(ANSIBLE_AWS_SECRET_ACCESS_KEY)'            >> $(PACKER_ISO_INFO)
	echo 'aws_region: $(ANSIBLE_AWS_DEFAULT_REGION)'            >> $(PACKER_ISO_INFO)
	echo 'docker_image_tag: $(ANSIBLE_DOCKER_IMAGE_TAG)'        >> $(PACKER_ISO_INFO)
	echo 'docker_registry: $(ANSIBLE_DOCKER_REGISTRY)'          >> $(PACKER_ISO_INFO)
	echo 'env: $(ENV)'                                          >> $(PACKER_ISO_INFO)
	echo 'file: $(PACKER_ISO_FILE)'                             >> $(PACKER_ISO_INFO)
	echo 'git_branch: $(ANSIBLE_GIT_VERSION)'                   >> $(PACKER_ISO_INFO)
	echo 'git_repository: $(ANSIBLE_GIT_REPOSITORY)'            >> $(PACKER_ISO_INFO)
	echo 'git_version: $(VERSION)'                              >> $(PACKER_ISO_INFO)
	echo 'host: $(hostname)'                                    >> $(PACKER_ISO_INFO)
	echo 'link: s3://$(AWS_S3_BUCKET)/$(AWS_S3_KEY)'            >> $(PACKER_ISO_INFO)
	echo 'name: $(iso_name)'                                    >> $(PACKER_ISO_INFO)
	echo 'nfs_disk: $(ANSIBLE_DISKS_NFS_DISK)'                  >> $(PACKER_ISO_INFO)
	echo 'pass: $(password)'                                    >> $(PACKER_ISO_INFO)
	echo 'size: $(iso_size)'                                    >> $(PACKER_ISO_INFO)
	echo 'ssh_key: $(ANSIBLE_SSH_PRIVATE_KEY)'                  >> $(PACKER_ISO_INFO)
	echo 'user: $(username)'                                    >> $(PACKER_ISO_INFO)
endef
