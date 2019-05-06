ANSIBLE_AWS_ACCESS_KEY_ID       ?= $(AWS_ACCESS_KEY_ID)
ANSIBLE_AWS_DEFAULT_OUTPUT      ?= $(AWS_DEFAULT_OUTPUT)
ANSIBLE_AWS_DEFAULT_REGION      ?= $(AWS_DEFAULT_REGION)
ANSIBLE_AWS_SECRET_ACCESS_KEY   ?= $(AWS_SECRET_ACCESS_KEY)
ANSIBLE_CONFIG                  ?= infra/ansible.cfg
ANSIBLE_DISKS_NFS_DISK          ?= $(MOUNT_NFS_DISK)
ANSIBLE_DISKS_NFS_OPTIONS       ?= $(MOUNT_NFS_OPTIONS)
ANSIBLE_DISKS_NFS_PATH          ?= $(MOUNT_NFS_PATH)
ANSIBLE_DOCKER_IMAGE_TAG        ?= $(DOCKER_IMAGE_TAG)
ANSIBLE_DOCKER_REGISTRY         ?= $(DOCKER_REGISTRY)
ANSIBLE_EXTRA_VARS              ?= target=localhost
ANSIBLE_GIT_DIRECTORY           ?= /src/$(MONOREPO)
ANSIBLE_GIT_KEY_FILE            ?= ~$(ANSIBLE_USERNAME)/.ssh/$(notdir $(ANSIBLE_SSH_PRIVATE_KEY))
ANSIBLE_GIT_REMOTE              ?= $(if $(filter $(ENV),preprod prod),upstream,origin)
ANSIBLE_GIT_REPOSITORY          ?= $(shell git remote get-url $(ANSIBLE_GIT_REMOTE) 2>/dev/null)
ANSIBLE_GIT_VERSION             ?= $(BRANCH)
ANSIBLE_INVENTORY               ?= infra/ansible/inventories
ANSIBLE_PLAYBOOK                ?= infra/ansible/playbook.yml
ANSIBLE_SSH_PRIVATE_KEY         ?= ~/.ssh/id_rsa
ANSIBLE_USERNAME                ?= root
ANSIBLE_VERBOSE                 ?= -v
CMDS                            += ansible ansible-playbook
ENV_VARS                        += ANSIBLE_AWS_ACCESS_KEY_ID ANSIBLE_AWS_DEFAULT_OUTPUT ANSIBLE_AWS_DEFAULT_REGION ANSIBLE_AWS_SECRET_ACCESS_KEY ANSIBLE_CONFIG ANSIBLE_DISKS_NFS_DISK ANSIBLE_DISKS_NFS_OPTIONS ANSIBLE_DISKS_NFS_PATH ANSIBLE_DOCKER_IMAGE_TAG ANSIBLE_DOCKER_REGISTRY ANSIBLE_EXTRA_VARS ANSIBLE_GIT_DIRECTORY ANSIBLE_GIT_KEY_FILE ANSIBLE_GIT_REMOTE ANSIBLE_GIT_REPOSITORY ANSIBLE_GIT_VERSION ANSIBLE_INVENTORY ANSIBLE_PLAYBOOK ANSIBLE_SSH_PRIVATE_KEY ANSIBLE_USERNAME ANSIBLE_VERBOSE

ifeq ($(DEBUG), true)
ANSIBLE_VERBOSE                 := -vvvv
endif

ifeq ($(DOCKER), true)
define ansible
	$(call run,$(DOCKER_SSH_AUTH) $(DOCKER_REPO)/ansible:local $(ANSIBLE_ARGS) $(ANSIBLE_VERBOSE) $(1))
endef
define ansible-playbook
	# TODO : run ansible in docker and target localhost outside docker
	IFS=$$'\n'; $(ECHO) env $(foreach var,$(ENV_VARS),$(if $($(var)),$(var)='$($(var))')) $(shell printenv |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } ($$1 in A)' .env.dist - 2>/dev/null) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') ansible-playbook $(ANSIBLE_ARGS) $(ANSIBLE_VERBOSE) $(1)
endef
define ansible-pull
	# TODO : run ansible in docker and target localhost outside docker
	IFS=$$'\n'; $(ECHO) env $(foreach var,$(ENV_VARS),$(if $($(var)),$(var)='$($(var))')) $(shell printenv |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } ($$1 in A)' .env.dist - 2>/dev/null) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') ansible-pull $(ANSIBLE_ARGS) $(ANSIBLE_VERBOSE) $(1)
endef
else
define ansible
	$(call run,ansible $(ANSIBLE_ARGS) $(ANSIBLE_VERBOSE) $(1))
endef
define ansible-playbook
	$(call run,ansible-playbook $(ANSIBLE_ARGS) $(ANSIBLE_VERBOSE) $(1))
endef
define ansible-pull
	$(call run,ansible-pull $(ANSIBLE_ARGS) $(ANSIBLE_VERBOSE) $(1))
endef
endif
