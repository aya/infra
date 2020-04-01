##
# DOCKER

.PHONY: docker-build docker-build-images
docker-build docker-build-images: $(DOCKER_IMAGES)

.PHONY: $(DOCKER_IMAGES)
$(DOCKER_IMAGES):
ifeq ($(DOCKER), true)
	$(call docker-build,$@)
endif

.PHONY: docker-build-%
docker-build-%:
	$(if $(wildcard docker/$*/Dockerfile),$(call docker-build,docker/$*))
	$(if $(findstring :,$*),$(eval DOCKERFILES := $(wildcard docker/$(subst :,/,$*)/Dockerfile)),$(eval DOCKERFILES := $(wildcard docker/$*/*/Dockerfile)))
	$(foreach dockerfile,$(DOCKERFILES),$(call docker-build,$(dir $(dockerfile)),$(DOCKER_REPOSITORY)/$(word 2,$(subst /, ,$(dir $(dockerfile)))):$(lastword $(subst /, ,$(dir $(dockerfile)))),"") && true)

.PHONY: docker-commit
docker-commit: stack
	$(eval DRYRUN_IGNORE := true)
	$(eval SERVICE ?= $(shell $(call docker-compose,--log-level critical config --services)))
	$(eval DRYRUN_IGNORE := false)
	$(foreach service,$(SERVICE),$(call docker-commit,$(service)))

.PHONY: docker-commit-%
docker-commit-%: stack
	$(eval DRYRUN_IGNORE := true)
	$(eval SERVICE ?= $(shell $(call docker-compose,--log-level critical config --services)))
	$(eval DRYRUN_IGNORE := false)
	$(foreach service,$(SERVICE),$(call docker-commit,$(service),,,$*))

.PHONY: docker-compose-build
docker-compose-build: stack
	$(call docker-compose,build $(SERVICE))

.PHONY: docker-compose-build
docker-compose-build-%: stack
	$(eval ENV:=$*)
	$(call docker-compose,build $(SERVICE))

.PHONY: docker-compose-config
docker-compose-config: stack
	$(call docker-compose,config)

.PHONY: docker-compose-config-%
docker-compose-config-%:
	$(call make,docker-compose-config DOCKER_BUILD_TARGET=$* ENV=$*)

.PHONY: docker-compose-connect
docker-compose-connect: SERVICE ?= $(DOCKER_SERVICE)
docker-compose-connect: stack docker-compose-up
	$(call docker-compose,exec $(SERVICE) $(DOCKER_SHELL)) || $(call docker-compose,exec $(SERVICE) /bin/sh) || true

.PHONY: docker-compose-down
docker-compose-down: stack
	$(if $(SERVICE),$(call docker-compose,rm -fs $(SERVICE)),$(call docker-compose,down $(DOCKER_COMPOSE_DOWN_OPTIONS)))

.PHONY: docker-compose-exec
docker-compose-exec: SERVICE ?= $(DOCKER_SERVICE)
docker-compose-exec: stack docker-compose-up
	$(call docker-compose-exec,$(SERVICE),$(ARGS)) || true

.PHONY: docker-compose-logs
docker-compose-logs: stack docker-compose-up
	$(call docker-compose,logs -f --tail=100 $(SERVICE)) || true

.PHONY: docker-compose-ps
docker-compose-ps: stack
	$(call docker-compose,ps)

.PHONY: docker-compose-rebuild
docker-compose-rebuild: stack
	$(call docker-compose,build --pull --no-cache $(SERVICE))

.PHONY: docker-compose-rebuild-%
docker-compose-rebuild-%: stack
	$(eval DOCKER_BUILD_TARGET:=$*)
	$(call docker-compose,build --pull --no-cache $(SERVICE))

.PHONY: docker-compose-recreate
docker-compose-recreate: stack docker-compose-rm docker-compose-up

.PHONY: docker-compose-restart
docker-compose-restart: stack
	$(call docker-compose,restart $(SERVICE))

.PHONY: docker-compose-rm
docker-compose-rm: stack
	$(call docker-compose,rm -fs $(SERVICE))

.PHONY: docker-compose-scale
docker-compose-scale: SERVICE ?= $(DOCKER_SERVICE)
docker-compose-scale: stack
	$(call docker-compose,up $(DOCKER_COMPOSE_UP_OPTIONS) --scale $(SERVICE)=$(NUM))

.PHONY: docker-compose-start
docker-compose-start: stack
	$(call docker-compose,start $(SERVICE))

.PHONY: docker-compose-stop
docker-compose-stop: stack
	$(call docker-compose,stop $(SERVICE))

.PHONY: docker-compose-up
docker-compose-up: stack
	$(call docker-compose,up $(DOCKER_COMPOSE_UP_OPTIONS) $(SERVICE))

.PHONY: docker-infra-base
docker-infra-base: bootstrap-infra
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),start up))
	$(call make,base,../infra)
endif
endif

.PHONY: docker-infra-images
docker-infra-images: bootstrap-infra
ifneq ($(wildcard ../infra),)
	$(eval DRYRUN_IGNORE := true)
	$(eval DOCKER_IMAGES_INFRA := $(or $(subst ',,$(DOCKER_IMAGES_INFRA)),$(shell $(call docker-compose,--log-level critical config --services))))
	$(eval DRYRUN_IGNORE := false)
	$(foreach image,$(DOCKER_IMAGES_INFRA),$(call make,docker-build-$(image),../infra))
endif

.PHONY: docker-infra-node
docker-infra-node: bootstrap-infra
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),start up))
	$(call make,$(patsubst %,node-%,$(MAKECMDGOALS)) SERVICE= STACK_NODE=node,../infra)
endif
endif

.PHONY: docker-infra-registry-login
docker-infra-registry-login:
	$(call make,aws-ecr-login)

.PHONY: docker-infra-services
docker-infra-services: bootstrap-infra
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),install ps start up))
	$(call make,$(MAKECMDGOALS) SERVICE= STACK=services,../infra)
endif
endif

.PHONY: docker-login
docker-login: bootstrap-infra
ifneq ($(wildcard ../infra),)
	$(call make,docker-infra-registry-login,../infra)
endif

.PHONY: docker-network-create
docker-network-create:
	[ -n "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Creating docker network $(DOCKER_NETWORK) ... " && $(ECHO) docker network create $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

.PHONY: docker-network-rm
docker-network-rm:
	[ -z "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Removing docker network $(DOCKER_NETWORK) ... " && $(ECHO) docker network rm $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

.PHONY: docker-plugin-install
docker-plugin-install:
	$(eval docker_plugin_state := $(shell docker plugin ls | awk '$$2 == "$(DOCKER_PLUGIN)" {print $$NF}') )
	$(if $(docker_plugin_state),$(if $(filter $(docker_plugin_state),false),echo -n "Enabling docker plugin $(DOCKER_PLUGIN) ... " && $(ECHO) docker plugin enable $(DOCKER_PLUGIN) >/dev/null 2>&1 && echo "done" || echo "ERROR"),echo -n "Installing docker plugin $(DOCKER_PLUGIN) ... " && $(ECHO) docker plugin install $(DOCKER_PLUGIN_OPTIONS) $(DOCKER_PLUGIN) $(DOCKER_PLUGIN_ARGS) >/dev/null 2>&1 && echo "done" || echo "ERROR")

.PHONY: docker-push
docker-push: stack
	$(eval DRYRUN_IGNORE := true)
	$(eval SERVICE ?= $(shell $(call docker-compose,--log-level critical config --services)))
	$(eval DRYRUN_IGNORE := false)
	$(foreach service,$(SERVICE),$(call docker-push,$(service)))

.PHONY: docker-push-%
docker-push-%: stack
	$(eval DRYRUN_IGNORE := true)
	$(eval SERVICE ?= $(shell $(call docker-compose,--log-level critical config --services)))
	$(eval DRYRUN_IGNORE := false)
	$(foreach service,$(SERVICE),$(call docker-push,$(service),,$*))

.PHONY: docker-rebuild-images
docker-rebuild-images:
	$(call make,docker-build-images DOCKER_BUILD_CACHE=false)

.PHONY: docker-rebuild-%
docker-rebuild-%:
	$(call make,docker-build-$* DOCKER_BUILD_CACHE=false)

.PHONY: docker-tag
docker-tag: stack
	$(eval DRYRUN_IGNORE := true)
	$(eval SERVICE ?= $(shell $(call docker-compose,--log-level critical config --services)))
	$(eval DRYRUN_IGNORE := false)
	$(foreach service,$(SERVICE),$(call docker-tag,$(service)))

.PHONY: docker-tag-%
docker-tag-%: stack
	$(eval DRYRUN_IGNORE := true)
	$(eval SERVICE ?= $(shell $(call docker-compose,--log-level critical config --services)))
	$(eval DRYRUN_IGNORE := false)
	$(foreach service,$(SERVICE),$(call docker-tag,$(service),,,,$*))
