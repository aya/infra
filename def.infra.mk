CMDS                            += ansible ansible-playbook aws base-exec node-exec openstack packer terraform
COMPOSE_IGNORE_ORPHANS          ?= true
CONTEXT                         += COMPOSE_PROJECT_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_NAME
DOCKER_SERVICE                  ?= mysql
GIT_AUTHOR_EMAIL                ?= $(shell git config user.email 2>/dev/null)
GIT_AUTHOR_NAME                 ?= $(shell git config user.name 2>/dev/null)
HOME                            ?= /home/$(USER)
REMOTE                          ?= ssh://git@github.com/1001Pharmacies/$(SUBREPO)
SETUP_NFSD                      ?= false
SETUP_NFSD_OSX_CONFIG           ?= nfs.server.bonjour=0 nfs.server.mount.regular_files=1 nfs.server.mount.require_resv_port=0 nfs.server.nfsd_threads=16 nfs.server.async=1
SETUP_SYSCTL                    ?= true
SETUP_SYSCTL_CONFIG             ?= vm.max_map_count=262144 vm.overcommit_memory=1 fs.file-max=8388608 net.core.somaxconn=1024
SHELL                           ?= /bin/sh
STACK                           ?= services
STACK_BASE                      ?= base
STACK_NODE                      ?= node

define setup-nfsd-osx
	$(eval dir:=$(or $(1),$(MONOREPO_DIR)))
	$(eval uid:=$(or $(2),$(UID)))
	$(eval gid:=$(or $(3),$(GID)))
	grep "$(dir)" /etc/exports >/dev/null 2>&1 || echo "$(dir) -alldirs -mapall=$(uid):$(gid) localhost" |sudo tee -a /etc/exports >/dev/null
	$(foreach config,$(SETUP_NFSD_OSX_CONFIG),grep "$(config)" /etc/nfs.conf >/dev/null 2>&1 || echo "$(config)" |sudo tee -a /etc/nfs.conf >/dev/null &&) true
	nfsd status >/dev/null || sudo nfsd enable
	showmount -e localhost |grep "$(dir)" >/dev/null 2>&1 || sudo nfsd restart
endef

ifeq ($(DOCKER), true)

define ansible
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_SSH_AUTH) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(DOCKER_REPO)/ansible:$(DOCKER_BUILD_TARGET) $(1)
endef
define ansible-playbook
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_SSH_AUTH) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) --entrypoint /usr/bin/ansible-playbook $(DOCKER_REPO)/ansible:$(DOCKER_BUILD_TARGET) $(1)
endef
define aws
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_SSH_AUTH) $(DOCKER_RUN_VOLUME) -v $$HOME/.aws:/root/.aws:ro $(DOCKER_RUN_WORKDIR) anigeo/awscli:latest $(1)
endef
define openstack
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_SSH_AUTH) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(DOCKER_REPO)/openstack:$(DOCKER_BUILD_TARGET) $(1)
endef
define packer
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_SSH_AUTH) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) --device /dev/kvm -v $(HOME):/home/$(USER) --name $(COMPOSE_PROJECT_NAME)_packer_1 -p 5900:5900 $(DOCKER_REPO)/packer:$(DOCKER_BUILD_TARGET) $(1)
endef

else

SHELL := /bin/bash
define ansible
	IFS=$$'\n'; $(ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') ansible $(1)
endef
define ansible-playbook
	IFS=$$'\n'; $(ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') ansible-playbook $(1)
endef
define aws
	IFS=$$'\n'; $(ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') aws $(1)
endef
define openstack
	IFS=$$'\n'; $(ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') openstack $(1)
endef
define packer
	IFS=$$'\n'; $(ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') packer $(1)
endef

endif
