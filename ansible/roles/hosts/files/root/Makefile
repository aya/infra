-include .env
ANSIBLE_CONFIG                  ?= infra/ansible.cfg
ANSIBLE_GIT_CHECKOUT            ?= master
ANSIBLE_GIT_DIRECTORY           ?= /src/1001Pharmacies
ANSIBLE_GIT_REPOSITORY          ?= ssh://git@github.com/1001Pharmacies/1001Pharmacies
ANSIBLE_INVENTORY               ?= infra/ansible/inventories
ANSIBLE_PLAYBOOK                ?= infra/ansible/playbook.yml
ANSIBLE_PRIVATE_KEY             ?= ~/.ssh/id_rsa
ANSIBLE_VERBOSE                 ?= -v
# dryrun = --check 
# --tags
# -vvv
ansible-pull:
	ansible-pull -U $(ANSIBLE_GIT_REPOSITORY) --private-key $(ANSIBLE_PRIVATE_KEY) -C $(ANSIBLE_GIT_CHECKOUT) -d $(ANSIBLE_GIT_DIRECTORY) --full -i $(ANSIBLE_INVENTORY) $(ANSIBLE_VERBOSE) $(ANSIBLE_PLAYBOOK)
