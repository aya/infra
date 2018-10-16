##
# STACK
include stack/*.mk

ifneq (,$(filter true,$(DOCKER)))
env_file_separator := --env-file
endif

bootstrap-docker: docker-network docker-sysctl

stack: $(patsubst %,stack-%,$(STACK))
	$(call .env)
	$(eval COMPOSE_FILE:=$(patsubst %,-f %,$(COMPOSE_FILE)))

stack-%: ## Start docker stack
	$(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.yml)
	$(if $(wildcard stack/$*/docker-compose.$(ENV).yml), $(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.$(ENV).yml))
	$(if $(wildcard stack/$*/.env.dist), $(call .env,stack/$*) $(eval ENV_FILE:=$(ENV_FILE) $(env_file_separator) stack/$*/.env))

start-up: ssh-add

