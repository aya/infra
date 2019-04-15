-include .env
ANSIBLE_CONFIG                  ?= infra/ansible.cfg
ANSIBLE_DIRECTORY               ?= /var/lib/ansible
ANSIBLE_GIT_CHECKOUT            ?= master
ANSIBLE_GIT_REPOSITORY          ?= ssh://git@github.com/1001Pharmacies/1001Pharmacies
ANSIBLE_INVENTORY               ?= infra/ansible/inventories
ANSIBLE_PLAYBOOK                ?= infra/ansible/playbook.yml
ANSIBLE_VERBOSE                 ?= -v

ansible-pull:
	ansible-pull -U $(ANSIBLE_GIT_REPOSITORY) --accept-host-key -C $(ANSIBLE_GIT_CHECKOUT) -d $(ANSIBLE_DIRECTORY) --full -i $(ANSIBLE_INVENTORY) $(ANSIBLE_VERBOSE) $(ANSIBLE_PLAYBOOK)
