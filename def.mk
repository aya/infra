# If the first argument is in CMDS
ifneq ($(filter $(CMDS),$(firstword $(MAKECMDGOALS))),)
  # set $ARGS with following arguments
  ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(ARGS):;@:)
endif

##
# MACROS

ifeq ($(DOCKER), true)
define ansible
	docker run --rm --name infra_ansible -it $(ANSIBLE_ENV) -v $$HOME/.ssh:/root/.ssh:ro -v $$PWD:/pwd -w /pwd ansible $(1)
endef
define ansible-playbook
	docker run --rm --name infra_ansible-playbook -it --entrypoint /usr/bin/ansible-playbook $(ANSIBLE_ENV) -v $$HOME/.ssh:/root/.ssh:ro -v $$PWD:/pwd -w /pwd ansible $(1)
endef
define aws
	docker run --rm --name infra_aws -it $(AWS_ENV) -v $$HOME/.aws:/root/.aws:ro -v $$PWD:/pwd -w /pwd aws $(1)
endef
define docker-compose
	docker run --rm --name infra_docker-compose -it -v /var/run/docker.sock:/var/run/docker.sock -v $$PWD:$$PWD -w $$PWD docker/compose:1.14.0 -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define openstack
	docker run --rm --name infra_openstack -it $(OPENSTACK_ENV) -v $$PWD:/pwd -w /pwd openstack $(1)
endef
define packer
	docker run --rm --name infra_packer --privileged -it $(PACKER_ENV) -v /lib/modules:/lib/modules -v $$HOME/.ssh:/root/.ssh -v $$PWD:/pwd -w /pwd packer $(1)
endef
else
define ansible
	$(ANSIBLE_ENV) ansible $(1)
endef
define ansible-playbook
	$(ANSIBLE_ENV) ansible-playbook $(1)
endef
define aws
	$(AWS_ENV) aws $(1)
endef
define docker-compose
	docker-compose -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define openstack
	$(OPENSTACK_ENV) openstack $(1)
endef
define packer
	 $(PACKER_ENV) packer $(1)
endef
endif

