CMDS                            += docker-compose-exec
COMPOSE_VERSION                 ?= 1.22.0
COMPOSE_PROJECT_NAME            ?= $(USER)_$(APP)_$(ENV)
COMPOSE_PROJECT_NAME_INFRA_BASE ?= $(USER)_infra_base
COMPOSE_PROJECT_NAME_INFRA_NODE ?= node_infra
COMPOSE_SERVICE_NAME            ?= $(subst _,-,$(COMPOSE_PROJECT_NAME))
DOCKER_BUILD_ARGS               ?= $(foreach var,$(DOCKER_BUILD_VARS),$(if $($(var)),--build-arg $(var)='$($(var))'))
DOCKER_BUILD_CACHE              ?= true
DOCKER_BUILD_TARGET             ?= local
DOCKER_BUILD_VARS               ?= APP BRANCH DOCKER_GID DOCKER_REPO GID GIT_AUTHOR_EMAIL GIT_AUTHOR_NAME TARGET UID USER VERSION
DOCKER_COMPOSE_DOWN_OPTIONS     ?=
DOCKER_GID                      ?= $(shell getent group docker |awk -F: '{print $$3}')
DOCKER_IMAGE_CLI                ?= cli:$(DOCKER_BUILD_TARGET)
DOCKER_IMAGE_SSH                ?= ssh:$(DOCKER_BUILD_TARGET)
DOCKER_IMAGE_TAG                ?= $(or $(TAG), $(DOCKER_BUILD_TARGET)$(addprefix -,$(DRONE_BUILD_NUMBER)))
DOCKER_IMAGES                   ?= $(dir $(wildcard docker/*/Dockerfile))
DOCKER_INFRA_CLI                ?= $(COMPOSE_PROJECT_NAME_INFRA_BASE)_cli
DOCKER_INFRA_SSH                ?= $(COMPOSE_PROJECT_NAME_INFRA_BASE)_ssh
DOCKER_NETWORK                  ?= $(ENV)
DOCKER_REPO                     ?= $(DOCKER_REPO_INFRA)
DOCKER_REPO_APP                 ?= $(USER)/$(APP)
DOCKER_REPO_INFRA               ?= $(USER)/infra
DOCKER_RUN_OPTIONS              ?= --rm -it
DOCKER_RUN_VOLUME               ?= -v $$PWD:$$PWD
DOCKER_RUN_WORKDIR              ?= -w $$PWD
DOCKER_SERVICE_INFRA_BASE       ?= cli ssh
DOCKER_SERVICE_INFRA_NODE       ?= consul fabio registrator
DOCKER_SHELL                    ?= $(SHELL)

ifeq ($(DOCKER), true)

DOCKER_SSH_AUTH                 := -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_INFRA_SSH):/tmp/ssh-agent:ro

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
DOCKER_RUN_VOLUME               := -v /var/run/docker.sock:/var/run/docker.sock -v $(MONOREPO_DIR):$(or $(WORKSPACE_DIR),$(MONOREPO_DIR))
endif

define docker-compose
	$(call run,docker/compose:$(COMPOSE_VERSION) $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) $(1))
endef
define docker-compose-exec
	$(call run,docker/compose:$(COMPOSE_VERSION) $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) exec -T $(1) sh -c '$(2)')
endef
define docker-run
	$(call run,$(1) $(2))
endef
ifeq ($(DRONE), true)
define exec
	$(call run,$(DOCKER_SSH_AUTH) ${DOCKER_REPO_INFRA}/${DOCKER_IMAGE_CLI} sh -c '$(1)')
endef
else
define exec
	$(ECHO) docker exec $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_INFRA_CLI)_1 sh -c '$(1)'
endef
endif
define run
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(1)
endef

else

SHELL                           := /bin/bash
define docker-compose
	$(call run,docker-compose $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) $(1))
endef
define docker-compose-exec
	$(call run,docker-compose $(patsubst %,-f %,$(COMPOSE_FILE)) -p $(COMPOSE_PROJECT_NAME) exec -T $(1) sh -c '$(2)')
endef
define docker-run
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(patsubst %,-e %,$(ENV_SYSTEM)) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(1) $(2)
endef
define exec
	$(call run,sh -c '$(1)')
endef
define run
	IFS=$$'\n'; $(ECHO) env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') $(1)
endef

endif

define docker-build
	$(eval path := $(1))
	$(eval tag := $(or $(2),$(DOCKER_REPO_APP)/$(lastword $(subst /, ,$(1))):$(DOCKER_BUILD_TARGET)))
	$(eval target := $(subst ",,$(subst ',,$(or $(3),$(DOCKER_BUILD_TARGET)))))
	$(eval image := $(shell docker images -q $(tag) 2>/dev/null))
	$(eval build_image := $(or $(filter $(DOCKER_BUILD_CACHE),false),$(if $(image),,true)))
	$(if $(build_image),$(ECHO) docker build $(DOCKER_BUILD_ARGS) --tag $(tag) $(if $(target),--target $(target)) $(path),echo "docker image $(tag) has id $(image)")
endef
define docker-volume-copy
	$(eval from:=$(1))
	$(eval to:=$(2))
	$(ECHO) docker volume inspect $(from) >/dev/null
	$(ECHO) docker volume inspect $(to) >/dev/null 2>&1 || $(ECHO) docker volume create $(to) >/dev/null
	$(ECHO) docker run --rm -v $(from):/from -v $(to):/to alpine ash -c "cd /from; cp -a . /to"
endef
