include ../env.mk
ANSIBLE_ENV=
ifeq ($(DEBUG), true)
	ANSIBLE_ARGS+= -vvvv
endif
ifeq ($(ENV), dev)
	ANSIBLE_ENV=
endif
ifeq ($(DOCKER), true)
	ANSIBLE_ENV:=$(patsubst %,-e %,$(ANSIBLE_ENV))
endif

CMDS := ansible ansible-playbook
include ../def.mk
include ../help.mk

.PHONY: help ansible ansible-playbook

all: build

build: ## Build docker image
	$(MAKE) --directory=.. build DOCKERS=ansible/docker/ansible

ansible:
	$(call ansible,$(ARGS))

ansible-playbook:
	$(call ansible-playbook,$(ARGS))

