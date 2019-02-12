##
# DOCKER

.PHONY: docker-base
docker-base:
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),start up))
	$(call make,-C ../infra $(patsubst %,base-%,$(MAKECMDGOALS)) STACK_BASE=base) || true
endif
endif

.PHONY: docker-build
docker-build: stack
	$(call docker-compose,build $(patsubst %,--build-arg %,$(DOCKER_BUILD_ARGS)) $(SERVICE))

.PHONY: docker-down
docker-down: stack
	$(call docker-compose,down $(DOCKER_COMPOSE_DOWN_OPTIONS))

.PHONY: docker-config
docker-config: stack
	$(call docker-compose,config)

.PHONY: docker-connect
docker-connect: SERVICE ?= $(DOCKER_SERVICE)
docker-connect: stack docker-up
	$(call docker-compose,exec $(SERVICE) /bin/zsh) || $(call docker-compose,exec $(SERVICE) /bin/bash) || $(call docker-compose,exec $(SERVICE) /bin/sh) || true

.PHONY: docker-exec
docker-exec: SERVICE ?= $(DOCKER_SERVICE)
docker-exec: stack docker-up
	$(call docker-compose-exec,$(SERVICE),$(ARGS)) || true

.PHONY: docker-logs
docker-logs: stack docker-up
	$(call docker-compose,logs -f --tail=100 $(SERVICE)) || true

.PHONY: docker-network
docker-network:
	[ -n "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Creating docker network $(DOCKER_NETWORK) ... " && $(DRYRUN_ECHO) docker network create $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

.PHONY: docker-network-rm
docker-network-rm:
	[ -z "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Removing docker network $(DOCKER_NETWORK) ... " && $(DRYRUN_ECHO) docker network rm $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

.PHONY: docker-node
docker-node:
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),start up))
	$(call make,-C ../infra $(patsubst %,node-%,$(MAKECMDGOALS)) STACK_NODE=node) || true
endif
endif

.PHONY: docker-ps
docker-ps: stack
	$(call docker-compose,ps)

.PHONY: docker-rebuild
docker-rebuild: stack
	$(call docker-compose,build $(patsubst %,--build-arg %,$(DOCKER_BUILD_ARGS)) --pull --no-cache $(SERVICE))

.PHONY: docker-recreate
docker-recreate: stack docker-rm docker-up

.PHONY: docker-restart
docker-restart: stack
	$(call docker-compose,restart $(SERVICE))

.PHONY: docker-rm
docker-rm: stack
	$(call docker-compose,rm -fs $(SERVICE))

.PHONY: docker-services
docker-services:
ifneq ($(wildcard ../infra),)
ifneq (,$(filter $(MAKECMDGOALS),install ps start up))
	$(call make,-C ../infra $(MAKECMDGOALS) STACK=services) || true
endif
endif

.PHONY: docker-start
docker-start: stack
	$(call docker-compose,start $(SERVICE))

.PHONY: docker-stop
docker-stop: stack
	$(call docker-compose,stop $(SERVICE))

.PHONY: docker-up
docker-up: stack
	$(call docker-compose,up -d $(SERVICE))
