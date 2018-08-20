##
# STACK
include stack/*.mk

bootstrap-docker: docker-network docker-sysctl node-up

stack: $(patsubst %,stack-%,$(STACK))
	$(eval COMPOSE_FILE:=$(patsubst %,-f %,$(COMPOSE_FILE)))
ifneq (,$(filter true,$(DOCKER) $(DRONE)))
	$(eval ENV_FILE:=$(patsubst %,--env-file %,$(ENV_FILE)))
endif

stack-%: ## Start docker stack
	$(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.yml)
	$(if $(wildcard stack/$*/docker-compose.$(ENV).yml), $(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.$(ENV).yml))
	$(if $(wildcard stack/$*/.env.dist), $(call .env,stack/$*) $(eval ENV_FILE:=$(ENV_FILE) stack/$*/.env))

start-up: ssh-add

