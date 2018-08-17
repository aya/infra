BRANCH                  := $(shell git branch --no-color 2>/dev/null |awk '$$1 == "*" {match($$0, "("FS")+"); print substr($$0, RSTART+RLENGTH);}')
CMDS                    := ansible ansible-playbook aws openstack packer
CONTEXT                 := BRANCH SUBREPO COMPOSE_PROJECT_NAME $(shell awk 'BEGIN {FS="="}; {print $$1}' .env.dist 2>/dev/null) ENV_SYSTEM
COMPOSE_VERSION         := 1.22.0
COMPOSE_IGNORE_ORPHANS  ?= true
COMPOSE_PROJECT_NAME    ?= $(ENV)_$(APP)
DEBUG                   ?= false
DOCKER                  ?= true
DOCKER_NETWORK          ?= $(ENV)
DRONE                   ?= false
ENV                     ?= local
ENV_FILE                ?= .env
ENV_SYSTEM              := $(shell printenv |awk -F '=' 'NR == FNR { A[$$1]; next } ($$1 in A)' .env.dist - 2>/dev/null |awk '{print} END {print "ENV=$(ENV)\nCOMPOSE_IGNORE_ORPHANS=$(COMPOSE_IGNORE_ORPHANS)"}' |awk -F "=" '!seen[$$1]++')
STACK                   ?= services
SUBREPO                 := $(notdir $(CURDIR))

ifneq (,$(filter true,$(DOCKER) $(DRONE)))
	ENV_SYSTEM:=$(patsubst %,-e %,$(ENV_SYSTEM))
endif

#
# If the first argument is in CMDS
ifneq ($(filter $(CMDS),$(firstword $(MAKECMDGOALS))),)
  # set $ARGS with following arguments
  ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(ARGS):;@:)
endif

##
# MACROS

ifeq ($(DRONE), true)
define docker-compose
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -v /var/run/docker.sock:/var/run/docker.sock -v $$(docker inspect $$(hostname) |awk 'BEGIN {FS=":"} $$0 ~ /_default:\/drone/ {gsub(/^[ \t\r\n]*"/,"",$$1); print $$1; exit}'):/drone -w $$PWD docker/compose:$(COMPOSE_VERSION) $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -v /var/run/docker.sock:/var/run/docker.sock -v $$(docker inspect $$(hostname) |awk 'BEGIN {FS=":"} $$0 ~ /_default:\/drone/ {gsub(/^[ \t\r\n]*"/,"",$$1); print $$1; exit}'):/drone -w $$PWD docker/compose:$(COMPOSE_VERSION) $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) exec -T $(1) sh -c '$(2)'
endef
else ifeq ($(DOCKER), true)
define docker-compose
    docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v $$PWD:$$PWD -w $$PWD docker/compose:$(COMPOSE_VERSION) $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
    docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -v /var/run/docker.sock:/var/run/docker.sock -v $$PWD:$$PWD -w $$PWD docker/compose:$(COMPOSE_VERSION) $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) exec -T $(1) sh -c '$(2)'
endef
else
SHELL := /bin/bash
define docker-compose
    IFS=$$'\n'; env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '!seen[$$1]++') docker-compose $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
    IFS=$$'\n'; env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '!seen[$$1]++') docker-compose $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) exec -T $(1) sh -c '$(2)'
endef
endif

ifeq ($(DOCKER), true)
define ansible
	docker run $(ENV_SYSTEM) --rm --name infra_ansible -it $(ANSIBLE_ENV) -v $$HOME/.ssh:/root/.ssh:ro -v $$PWD:/pwd -w /pwd ansible $(1)
endef
define ansible-playbook
	docker run $(ENV_SYSTEM) --rm --name infra_ansible-playbook -it --entrypoint /usr/bin/ansible-playbook $(ANSIBLE_ENV) -v $$HOME/.ssh:/root/.ssh:ro -v $$PWD:/pwd -w /pwd ansible $(1)
endef
define aws
	docker run $(ENV_SYSTEM) --rm --name infra_aws -it $(AWS_ENV) -v $$HOME/.aws:/root/.aws:ro -v $$PWD:/pwd -w /pwd aws $(1)
endef
define openstack
	docker run $(ENV_SYSTEM) --rm --name infra_openstack -it $(OPENSTACK_ENV) -v $$PWD:/pwd -w /pwd openstack $(1)
endef
define packer
	docker run $(ENV_SYSTEM) --rm --name infra_packer --privileged -it $(PACKER_ENV) -v /lib/modules:/lib/modules -v $$HOME/.ssh:/root/.ssh -v $$PWD:/pwd -w /pwd packer $(1)
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
