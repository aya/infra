ANSIBLE_AWS_DEFAULT_OUTPUT      ?= $(AWS_DEFAULT_OUTPUT)
ANSIBLE_AWS_DEFAULT_REGION      ?= $(AWS_DEFAULT_REGION)
ANSIBLE_AWS_ACCESS_KEY_ID       ?= $(AWS_ACCESS_KEY_ID)
ANSIBLE_AWS_SECRET_ACCESS_KEY   ?= $(AWS_SECRET_ACCESS_KEY)
ANSIBLE_EXTRA_VARS              ?= target=localhost
ANSIBLE_CONFIG                  ?= infra/ansible.cfg
ANSIBLE_GIT_DIRECTORY           ?= /src/$(MONOREPO)
ANSIBLE_GIT_KEY_FILE            ?= ~$(ANSIBLE_USERNAME)/.ssh/$(notdir $(ANSIBLE_SSH_PRIVATE_KEY))
ANSIBLE_GIT_REMOTE              ?= origin
ANSIBLE_GIT_REPOSITORY          ?= $(shell git remote get-url $(ANSIBLE_GIT_REMOTE) 2>/dev/null)
ANSIBLE_GIT_VERSION             ?= $(or $(TAG),$(BRANCH))
ANSIBLE_INVENTORY               ?= infra/ansible/inventories
ANSIBLE_PLAYBOOK                ?= infra/ansible/playbook.yml
ANSIBLE_SSH_PRIVATE_KEY         ?= ~/.ssh/id_rsa
ANSIBLE_USERNAME                ?= root
ANSIBLE_VERBOSE                 ?= -v
ifeq ($(DEBUG), true)
ANSIBLE_VERBOSE                 := -vvvv
endif
CMDS                            += ansible ansible-playbook
ENV_SYSTEM_VARS                 += ANSIBLE_AWS_DEFAULT_OUTPUT ANSIBLE_AWS_DEFAULT_REGION ANSIBLE_AWS_ACCESS_KEY_ID ANSIBLE_AWS_SECRET_ACCESS_KEY ANSIBLE_EXTRA_VARS ANSIBLE_CONFIG ANSIBLE_GIT_DIRECTORY ANSIBLE_GIT_KEY_FILE ANSIBLE_GIT_REMOTE ANSIBLE_GIT_REPOSITORY ANSIBLE_GIT_VERSION ANSIBLE_INVENTORY ANSIBLE_PLAYBOOK ANSIBLE_SSH_PRIVATE_KEY ANSIBLE_USERNAME ANSIBLE_VERBOSE

ifeq ($(DOCKER), true)
define ansible
	$(call run,$(DOCKER_SSH_AUTH) $(DOCKER_REPO)/ansible:$(DOCKER_BUILD_TARGET) $(ANSIBLE_VERBOSE) $(1))
endef
define ansible-playbook
	$(call run,$(DOCKER_SSH_AUTH) --entrypoint /usr/bin/ansible-playbook $(DOCKER_REPO)/ansible:$(DOCKER_BUILD_TARGET) $(ANSIBLE_VERBOSE) $(1))
endef
else
define ansible
	$(call run,ansible $(ANSIBLE_VERBOSE) $(1))
endef
define ansible-playbook
	$(call run,ansible-playbook $(ANSIBLE_VERBOSE) $(1))
endef
endif
