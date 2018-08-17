##
# STACK
include stack/*.mk

bootstrap-docker: docker-network docker-sysctl node-up

node: node-up

node-down:
	DOCKER_NETWORK=node COMPOSE_PROJECT_NAME=node_infra $(MAKE) docker-down STACK=node DOCKER_NETWORK=node

node-down-rm:
	DOCKER_NETWORK=node COMPOSE_PROJECT_NAME=node_infra $(MAKE) docker-down-rm docker-network-rm STACK=node DOCKER_NETWORK=node

node-ps:
	DOCKER_NETWORK=node COMPOSE_PROJECT_NAME=node_infra $(MAKE) docker-ps STACK=node

node-up:
	DOCKER_NETWORK=node COMPOSE_PROJECT_NAME=node_infra $(MAKE) docker-network docker-openssl docker-up docker-network-connect STACK=node DOCKER_NETWORK=node

stack: $(patsubst %,stack-%,$(STACK))
	$(eval COMPOSE_FILE:=$(patsubst %,-f %,$(COMPOSE_FILE)))
ifneq (,$(filter true,$(DOCKER) $(DRONE)))
	$(eval ENV_FILE:=$(patsubst %,--env-file %,$(ENV_FILE)))
endif

stack-%: ## Start docker stack
	$(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.yml)
	$(if $(wildcard stack/$*/.env.dist), $(call .env,stack/$*) $(eval ENV_FILE:=$(ENV_FILE) stack/$*/.env))

start-up: ssh-add

