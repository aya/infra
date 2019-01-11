CMDS                            ?= ansible ansible-playbook aws base-exec docker-exec exec node-exec openstack packer
COMPOSE_IGNORE_ORPHANS          ?= true
CONTEXT                         += COMPOSE_PROJECT_NAME
DOCKER_SERVICE                  ?= mysql
NFS_MOUNT                       ?= false
REMOTE                          ?= ssh://git@github.com/1001Pharmacies/$(SUBREPO)
STACK                           ?= services
STACK_BASE                      ?= base
STACK_NODE                      ?= node

ifeq ($(DOCKER), true)
define ansible
	docker run $(ENV_SYSTEM) --rm -it $(ANSIBLE_ENV) -v $$HOME/.ssh:/root/.ssh:ro -v $$PWD:/pwd -w /pwd ansible $(1)
endef
define ansible-playbook
	docker run $(ENV_SYSTEM) --rm -it --entrypoint /usr/bin/ansible-playbook $(ANSIBLE_ENV) -v $$HOME/.ssh:/root/.ssh:ro -v $$PWD:/pwd -w /pwd ansible $(1)
endef
define aws
	docker run $(ENV_SYSTEM) --rm -it $(AWS_ENV) -v $$HOME/.aws:/root/.aws:ro -v $$PWD:/pwd -w /pwd aws $(1)
endef
define openstack
	docker run $(ENV_SYSTEM) --rm -it $(OPENSTACK_ENV) -v $$PWD:/pwd -w /pwd openstack $(1)
endef
define packer
	docker run $(ENV_SYSTEM) --rm -it --name infra_packer --privileged $(PACKER_ENV) -v /lib/modules:/lib/modules -v $$HOME/.ssh:/root/.ssh -v $$PWD:/pwd -w /pwd packer $(1)
endef
else
define ansible
	$(ENV_SYSTEM) $(ANSIBLE_ENV) ansible $(1)
endef
define ansible-playbook
	$(ENV_SYSTEM) $(ANSIBLE_ENV) ansible-playbook $(1)
endef
define aws
	$(ENV_SYSTEM) $(AWS_ENV) aws $(1)
endef
define openstack
	$(ENV_SYSTEM) $(OPENSTACK_ENV) openstack $(1)
endef
define packer
	$(ENV_SYSTEM) $(PACKER_ENV) packer $(1)
endef
endif
