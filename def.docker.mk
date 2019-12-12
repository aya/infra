CMDS                            += docker-compose-exec
COMPOSE_VERSION                 ?= 1.24.1
COMPOSE_PROJECT_NAME            ?= $(USER)_$(ENV)_$(APP)
COMPOSE_PROJECT_NAME_INFRA      ?= $(USER)_$(ENV)_infra
COMPOSE_PROJECT_NAME_INFRA_NODE ?= node_infra
COMPOSE_SERVICE_NAME            ?= $(subst _,-,$(COMPOSE_PROJECT_NAME))
DOCKER_BUILD_ARGS               ?= $(foreach var,$(DOCKER_BUILD_VARS),$(if $($(var)),--build-arg $(var)='$($(var))'))
DOCKER_BUILD_CACHE              ?= true
DOCKER_BUILD_TARGET             ?= $(if $(filter-out $(APP),infra),$(if $(filter $(ENV),local tests preprod prod),$(ENV),local),local)
DOCKER_BUILD_VARS               ?= APP BRANCH DOCKER_GID DOCKER_REPOSITORY GID GIT_AUTHOR_EMAIL GIT_AUTHOR_NAME TARGET UID USER VERSION
DOCKER_COMPOSE_DOWN_OPTIONS     ?=
DOCKER_GID                      ?= $(call getent-group,docker)
DOCKER_IMAGE                    ?= $(DOCKER_IMAGE_CLI)
DOCKER_IMAGE_CLI                ?= $(DOCKER_REPOSITORY_INFRA)/cli
DOCKER_IMAGE_SSH                ?= $(DOCKER_REPOSITORY_INFRA)/ssh
DOCKER_IMAGE_TAG                ?= $(if $(filter-out $(APP),infra),$(if $(filter $(ENV),preprod prod),$(VERSION),$(if $(DRONE_BUILD_NUMBER),$(DRONE_BUILD_NUMBER),latest)),latest)
DOCKER_IMAGES                   ?= $(dir $(wildcard docker/*/Dockerfile))
DOCKER_NAME                     ?= $(DOCKER_NAME_CLI)
DOCKER_NAME_CLI                 ?= $(COMPOSE_PROJECT_NAME_INFRA)_cli
DOCKER_NAME_SSH                 ?= $(COMPOSE_PROJECT_NAME_INFRA)_ssh
DOCKER_NETWORK                  ?= $(ENV)
DOCKER_PLUGIN                   ?= rexray/s3fs:latest
DOCKER_PLUGIN_ARGS              ?= $(foreach var,$(DOCKER_PLUGIN_VARS),$(if $($(var)),$(var)='$($(var))'))
DOCKER_PLUGIN_OPTIONS           ?= --grant-all-permissions
DOCKER_PLUGIN_VARS              ?= S3FS_ACCESSKEY S3FS_OPTIONS S3FS_SECRETKEY S3FS_REGION
DOCKER_REGISTRY                 ?= 261323802359.dkr.ecr.eu-west-1.amazonaws.com
DOCKER_REGISTRY_USERNAME        ?= 1001pharmacies
DOCKER_REGISTRY_REPOSITORY      ?= $(addsuffix /,$(DOCKER_REGISTRY))$(subst $(USER),$(DOCKER_REGISTRY_USERNAME),$(DOCKER_REPOSITORY))
DOCKER_REPOSITORY               ?= $(subst _,/,$(COMPOSE_PROJECT_NAME))
DOCKER_REPOSITORY_INFRA         ?= $(subst _,/,$(COMPOSE_PROJECT_NAME_INFRA))
DOCKER_REPOSITORY_INFRA_NODE    ?= $(subst _,/,$(COMPOSE_PROJECT_NAME_INFRA_NODE))
DOCKER_RUN_OPTIONS              ?= --rm -it
DOCKER_RUN_VOLUME               ?= -v $$PWD:$$PWD
DOCKER_RUN_WORKDIR              ?= -w $$PWD
DOCKER_SERVICES_INFRA_BASE      ?= cli ssh
DOCKER_SERVICES_INFRA_NODE      ?= consul fabio registrator
DOCKER_SHELL                    ?= $(SHELL)
DOCKER_VOLUME_SSH               ?= $(COMPOSE_PROJECT_NAME_INFRA)_ssh
ENV_VARS                        += COMPOSE_PROJECT_NAME COMPOSE_SERVICE_NAME DOCKER_BUILD_TARGET DOCKER_GID DOCKER_HOST_IFACE DOCKER_HOST_INET DOCKER_IMAGE_TAG DOCKER_NETWORK DOCKER_REGISTRY DOCKER_REPOSITORY DOCKER_REPOSITORY_INFRA DOCKER_REPOSITORY_INFRA_NODE DOCKER_SHELL DOCKER_VOLUME_SSH
S3FS_ACCESSKEY                  ?= $(shell $(call conf,$(HOME)/.aws/credentials,$(or $(AWS_PROFILE),default),aws_access_key_id))
S3FS_OPTIONS                    ?= allow_other,nonempty,use_path_request_style,url=https://s3-eu-west-1.amazonaws.com
S3FS_SECRETKEY                  ?= $(shell $(call conf,$(HOME)/.aws/credentials,$(or $(AWS_PROFILE),default),aws_secret_access_key))
S3FS_REGION                     ?= eu-west-1

# https://github.com/docker/libnetwork/pull/2348
ifeq ($(HOST_SYSTEM), DARWIN)
DOCKER_HOST_IFACE               ?= $(shell docker run --rm -it --net=host alpine /sbin/ip -4 route list match 0/0 2>/dev/null |awk '{print $$5}' |awk '!seen[$$0]++' |head -1)
DOCKER_HOST_INET                ?= $(shell docker run --rm -it --net=host alpine /sbin/ip -4 addr show $(DOCKER_HOST_IFACE) 2>/dev/null |awk '$$1 == "inet" {sub(/\/.*/,"",$$2); print $$2}')
DOCKER_INTERNAL_DOCKER_GATEWAY  ?= $(shell docker run --rm -it alpine getent hosts gateway.docker.internal |awk '{print $$1}' |head -1)
DOCKER_INTERNAL_DOCKER_HOST     ?= $(shell docker run --rm -it alpine getent hosts host.docker.internal |awk '{print $$1}' |head -1)
else
DOCKER_HOST_IFACE               ?= $(shell /sbin/ip -4 route list match 0/0 2>/dev/null |awk '{print $$5}' |awk '!seen[$$0]++' |head -1)
DOCKER_HOST_INET                ?= $(shell /sbin/ip -4 addr show $(DOCKER_HOST_IFACE) 2>/dev/null |awk '$$1 == "inet" {sub(/\/.*/,"",$$2); print $$2}')
DOCKER_INTERNAL_DOCKER_GATEWAY  ?= $(shell /sbin/ip -4 route list match 0/0 2>/dev/null |awk '{print $$3}' |awk '!seen[$$0]++' |head -1)
DOCKER_INTERNAL_DOCKER_HOST     ?= $(shell /sbin/ip addr show docker0 2>/dev/null |awk '$$1 == "inet" {sub(/\/.*/,"",$$2); print $$2}')
endif

ifeq ($(DOCKER), true)

DOCKER_SSH_AUTH                 := -e SSH_AUTH_SOCK=/tmp/ssh-agent/socket -v $(DOCKER_VOLUME_SSH):/tmp/ssh-agent:ro

ifeq ($(DRONE), true)
DOCKER_RUN_OPTIONS              := --rm --network $(DOCKER_NETWORK)
DOCKER_RUN_VOLUME               := -v /var/run/docker.sock:/var/run/docker.sock -v $$(docker inspect $$(basename $$(cat /proc/1/cpuset)) 2>/dev/null |awk 'BEGIN {FS=":"} $$0 ~ /[[a-z0-9]]*:\/drone/ {gsub(/^[ \t\r\n]*"/,"",$$1); print $$1; exit}'):/drone
ENV_SUFFIX                      := $(DRONE_BUILD_NUMBER)
HOSTNAME                        := $(word 1,$(subst ., ,$(DRONE_RUNNER_HOSTNAME)))
ifneq ($(APP), infra)
COMPOSE_PROJECT_NAME            := $(USER)_$(ENV)$(ENV_SUFFIX)_$(APP)
COMPOSE_SERVICE_NAME            := $(subst _,-,$(COMPOSE_PROJECT_NAME))
DOCKER_REPOSITORY               := $(USER)/$(ENV)/$(APP)
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
	$(call run,$(DOCKER_SSH_AUTH) $(DOCKER_IMAGE) sh -c '$(1)')
endef
else
define exec
	$(ECHO) docker exec $(ENV_ARGS) $(DOCKER_RUN_WORKDIR) $(DOCKER_NAME) sh -c '$(1)'
endef
endif
define run
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(ENV_ARGS) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(1)
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
	$(ECHO) docker run $(DOCKER_RUN_OPTIONS) $(patsubst %,--env-file %,$(ENV_FILE)) $(foreach var,$(ENV_VARS),$(if $($(var)),-e $(var)='$($(var))')) $(shell printenv |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } ($$1 in A) {print "-e "$$0}' .env.dist - 2>/dev/null) $(DOCKER_RUN_VOLUME) $(DOCKER_RUN_WORKDIR) $(1) $(2)
endef
define exec
	$(call run,sh -c '$(1)')
endef
define run
	IFS=$$'\n'; $(ECHO) env $(ENV_ARGS) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '$$1 ~! /^\(#|$$\)/') $(1)
endef

endif

define exec-ssh
	$(eval hosts := $(1))
	$(eval command := $(2))
	$(eval user := $(or $(3),root))
	$(foreach host,$(hosts),$(call exec,ssh $(user)@$(host) "$(command)") &&) true
endef

define force
	while true; do [ $$(ps x |awk 'BEGIN {nargs=split("'"$$*"'",args)} $$field == args[1] { matched=1; for (i=1;i<=NF-field;i++) { if ($$(i+field) == args[i+1]) {matched++} } if (matched == nargs) {found++} } END {print found+0}' field=4) -eq 0 ] && $(ECHO) $(1) || sleep 1; done
endef

define docker-build
	$(eval path := $(1))
	$(eval tag := $(or $(2),$(DOCKER_REPOSITORY)/$(lastword $(subst /, ,$(1))):$(DOCKER_IMAGE_TAG)))
	$(eval target := $(subst ",,$(subst ',,$(or $(3),$(DOCKER_BUILD_TARGET)))))
	$(eval image_id := $(shell docker images -q $(tag) 2>/dev/null))
	$(eval build_image := $(or $(filter $(DOCKER_BUILD_CACHE),false),$(if $(image_id),,true)))
	$(if $(build_image),$(ECHO) docker build $(DOCKER_BUILD_ARGS) --tag $(tag) $(if $(target),--target $(target)) $(path),$(if $(filter $(VERBOSE),true),echo "docker image $(tag) has id $(image_id)",true))
endef
define docker-commit
	$(eval service := $(or $(1),$(DOCKER_SERVICE)))
	$(eval container := $(or $(2),$(firstword $(shell $(call docker-compose,--log-level critical ps -q $(service))))))
	$(eval repository := $(or $(3),$(DOCKER_REPOSITORY)/$(service)))
	$(eval tag := $(or $(4),$(DOCKER_IMAGE_TAG)))
	$(if $(filter $(VERBOSE),true),echo docker commit $(container) $(repository):$(tag))
	$(ECHO) docker commit $(container) $(repository):$(tag)
endef
define docker-push
	$(eval service := $(or $(1),$(DOCKER_SERVICE)))
	$(eval name := $(or $(2),$(DOCKER_REGISTRY_REPOSITORY)/$(service)))
	$(eval tag := $(or $(3),$(DOCKER_IMAGE_TAG)))
	$(if $(filter $(VERBOSE),true),echo docker push $(name):$(tag))
	$(ECHO) docker push $(name):$(tag)
endef
define docker-tag
	$(eval service := $(or $(1),$(DOCKER_SERVICE)))
	$(eval source := $(or $(2),$(DOCKER_REPOSITORY)/$(service)))
	$(eval source_tag := $(or $(3),$(DOCKER_IMAGE_TAG)))
	$(eval target := $(or $(4),$(DOCKER_REGISTRY_REPOSITORY)/$(service)))
	$(eval target_tag := $(or $(5),$(source_tag)))
	$(if $(filter $(VERBOSE),true),echo docker tag $(source):$(source_tag) $(target):$(target_tag))
	$(ECHO) docker tag $(source):$(source_tag) $(target):$(target_tag)
endef
define docker-volume-copy
	$(eval from:=$(1))
	$(eval to:=$(2))
	$(ECHO) docker volume inspect $(from) >/dev/null
	$(ECHO) docker volume inspect $(to) >/dev/null 2>&1 || $(ECHO) docker volume create $(to) >/dev/null
	$(ECHO) docker run --rm -v $(from):/from -v $(to):/to alpine ash -c "cd /from; cp -a . /to"
endef
