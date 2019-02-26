COMPOSE_VERSION                 ?= 1.22.0
COMPOSE_PROJECT_NAME            ?= $(USER)_$(APP)_$(ENV)
COMPOSE_PROJECT_NAME_INFRA_BASE ?= $(USER)_infra
COMPOSE_PROJECT_NAME_INFRA_NODE ?= node_infra
COMPOSE_SERVICE_NAME            ?= $(subst _,-,$(COMPOSE_PROJECT_NAME))
DOCKER_BUILD_TARGET             ?= local
DOCKER_COMPOSE_DOWN_OPTIONS     ?=
DOCKER_IMAGE_CLI                ?= cli:$(DOCKER_BUILD_TARGET)
DOCKER_IMAGE_REPO               ?= $(USER)/$(APP)
DOCKER_IMAGE_REPO_BASE          ?= $(USER)/infra
DOCKER_IMAGE_SSH                ?= ssh:$(DOCKER_BUILD_TARGET)
DOCKER_IMAGE_TAG                ?= $(or $(TAG), $(DOCKER_BUILD_TARGET)$(addprefix -,$(DRONE_BUILD_NUMBER)))
DOCKER_INFRA_CLI                ?= $(COMPOSE_PROJECT_NAME_INFRA_BASE)_cli
DOCKER_INFRA_SSH                ?= $(COMPOSE_PROJECT_NAME_INFRA_BASE)_ssh
DOCKER_NETWORK                  ?= $(ENV)
DOCKER_RUN_OPTIONS              ?= --rm -it
DOCKER_RUN_VOLUME               ?= -v $$PWD:$$PWD
DOCKER_RUN_WORKDIR              ?= -w $$PWD
DOCKER_SERVICE_INFRA_BASE       ?= cli ssh php5.6
DOCKER_SERVICE_INFRA_NODE       ?= consul fabio registrator

ifeq ($(DOCKER), true)

ifeq ($(DRONE), true)
DOCKER_RUN_OPTIONS              := --rm
DOCKER_RUN_VOLUME               := -v /var/run/docker.sock:/var/run/docker.sock -v $$(docker inspect $$(hostname) 2>/dev/null |awk 'BEGIN {FS=":"} $$0 ~ /[[a-z0-9]]*:\/drone/ {gsub(/^[ \t\r\n]*"/,"",$$1); print $$1; exit}'):/drone
ENV_SUFFIX                      := $(DRONE_BUILD_NUMBER)
HOSTNAME                        := $(word 1,$(subst ., ,$(DRONE_RUNNER_HOSTNAME)))
ifneq ($(APP), infra)
COMPOSE_PROJECT_NAME            := $(USER)_$(APP)_$(ENV)_$(ENV_SUFFIX)
COMPOSE_SERVICE_NAME            := $(subst _,-,$(COMPOSE_PROJECT_NAME))
endif
else
DOCKER_RUN_VOLUME               := -v /var/run/docker.sock:/var/run/docker.sock -v $$PWD:$$PWD
endif

define docker-compose
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) docker/compose:$(COMPOSE_VERSION) $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) docker/compose:$(COMPOSE_VERSION) $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) exec -T $(1) sh -c '$(2)'
endef
define docker-run
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(1) $(2)
endef
ifeq ($(DRONE), true)
define exec
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_INFRA_SSH):/tmp/ssh-agent:ro $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) ${DOCKER_IMAGE_REPO_BASE}/${DOCKER_IMAGE_CLI} sh -c '$(1)'
endef
else
define exec
	$(DRYRUN_ECHO) docker exec $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_INFRA_CLI)_1 sh -c '$(1)'
endef
endif
define run
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_INFRA_SSH):/tmp/ssh-agent:ro $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) ${DOCKER_IMAGE_REPO_BASE}/${DOCKER_IMAGE_CLI} sh -c '$(1)'
endef
define ansible
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_INFRA_SSH):/tmp/ssh-agent:ro $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) ansible $(1)
endef
define ansible-playbook
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_INFRA_SSH):/tmp/ssh-agent:ro $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) --entrypoint /usr/bin/ansible-playbook ansible $(1)
endef
define aws
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_INFRA_SSH):/tmp/ssh-agent:ro $(DOCKER_RUN_VOLUME) -v $$HOME/.aws:/root/.aws:ro $(DOCKER_RUN_WORKDIR) aws $(1)
endef
define openstack
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_INFRA_SSH):/tmp/ssh-agent:ro $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) openstack $(1)
endef
define packer
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_INFRA_SSH):/tmp/ssh-agent:ro $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) --name infra_packer --privileged -v /lib/modules:/lib/modules packer $(1)
endef

else

SHELL := /bin/bash
define docker-compose
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$1 ~! /^\(#|$\)/') docker-compose $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$1 ~! /^\(#|$\)/') docker-compose $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) exec $(1) sh -c '$(2)'
endef
define docker-run
	$(DRYRUN_ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(1) $(2)
endef
define exec
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') sh -c '$(1)'
endef
define run
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') sh -c '$(1)'
endef
define ansible
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') ansible $(1)
endef
define ansible-playbook
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') ansible-playbook $(1)
endef
define aws
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') aws $(1)
endef
define openstack
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') openstack $(1)
endef
define packer
	IFS=$$'\n'; $(DRYRUN_ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') packer $(1)
endef

endif
