##
# DOCKER

.PHONY: $(DOCKERS)
$(DOCKERS):
ifeq ($(DOCKER), true)
	$(call docker-build,$@)
endif

.PHONY: docker-build-images
docker-build-images: $(DOCKERS)

.PHONY: docker-build-%
docker-build-%:
	$(if $(wildcard docker/$*/Dockerfile),$(call docker-build,docker/$*))
	$(if $(findstring :,$*),$(eval DOCKERFILES := $(wildcard docker/$(subst :,/,$*)/Dockerfile)),$(eval DOCKERFILES := $(wildcard docker/$*/*/Dockerfile)))
	$(foreach dockerfile,$(DOCKERFILES),$(call docker-build,$(dir $(dockerfile)),$(DOCKER_REPO_APP)/$(word 2,$(subst /, ,$(dir $(dockerfile)))):$(lastword $(subst /, ,$(dir $(dockerfile)))),"") && true)

.PHONY: docker-compose-build
docker-compose-build: stack
	$(call docker-compose,build $(DOCKER_BUILD_ARGS) $(SERVICE))

.PHONY: docker-compose-config
docker-compose-config: stack
	$(call docker-compose,config)

.PHONY: docker-compose-connect
docker-compose-connect: SERVICE ?= $(DOCKER_SERVICE)
docker-compose-connect: stack docker-compose-up
	$(call docker-compose,exec $(SERVICE) /bin/zsh) || $(call docker-compose,exec $(SERVICE) /bin/bash) || $(call docker-compose,exec $(SERVICE) /bin/sh) || true

.PHONY: docker-compose-down
docker-compose-down: stack
	$(call docker-compose,down $(DOCKER_COMPOSE_DOWN_OPTIONS))

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
	$(call docker-compose,build $(patsubst %,--build-arg %,$(DOCKER_BUILD_ARGS)) --pull --no-cache $(SERVICE))

.PHONY: docker-compose-recreate
docker-compose-recreate: stack docker-compose-rm docker-compose-up

.PHONY: docker-compose-restart
docker-compose-restart: stack
	$(call docker-compose,restart $(SERVICE))

.PHONY: docker-compose-rm
docker-compose-rm: stack
	$(call docker-compose,rm -fs $(SERVICE))

.PHONY: docker-compose-start
docker-compose-start: stack
	$(call docker-compose,start $(SERVICE))

.PHONY: docker-compose-stop
docker-compose-stop: stack
	$(call docker-compose,stop $(SERVICE))

.PHONY: docker-compose-up
docker-compose-up: stack
	$(call docker-compose,up -d $(SERVICE))

.PHONY: docker-infra-base
docker-infra-base: bootstrap-infra
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),start up))
	$(call make,$(patsubst %,base-%,$(MAKECMDGOALS)) STACK_BASE=base,../infra)
endif
endif

.PHONY: docker-infra-images
docker-infra-images: bootstrap-infra
ifneq ($(wildcard ../infra),)
	$(eval DRYRUN_IGNORE := true)
	$(eval DOCKER_INFRA_IMAGES := $(or $(DOCKER_INFRA_IMAGES),$(shell $(call docker-compose,--log-level critical config --services))))
	$(eval DRYRUN_IGNORE := false)
	$(foreach image,$(DOCKER_INFRA_IMAGES),$(call make,build-$(image),../infra))
endif

.PHONY: docker-infra-node
docker-infra-node: bootstrap-infra
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),start up))
	$(call make,$(patsubst %,node-%,$(MAKECMDGOALS)) STACK_NODE=node,../infra)
endif
endif

.PHONY: docker-infra-services
docker-infra-services: bootstrap-infra
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),install ps start up))
	$(call make,$(MAKECMDGOALS) STACK=services,../infra)
endif
endif

.PHONY: docker-network-create
docker-network-create:
	[ -n "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Creating docker network $(DOCKER_NETWORK) ... " && $(DRYRUN_ECHO) docker network create $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

.PHONY: docker-network-rm
docker-network-rm:
	[ -z "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Removing docker network $(DOCKER_NETWORK) ... " && $(DRYRUN_ECHO) docker network rm $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

.PHONY: docker-rebuild-images
docker-rebuild-images:
	$(call make,docker-build-images DOCKER_BUILD_CACHE=false)

.PHONY: docker-rebuild-%
docker-rebuild-%:
	$(call make,docker-build-$* DOCKER_BUILD_CACHE=false)
