.SILENT:
.PHONY: help

## Colors
COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m

## Defaults
DOCKER ?= true
DOCKER_NETWORK ?= meup
DOCKER_COMPOSE_PROJECT ?= pdns
DIR := ${CURDIR}

## Help
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

#############
# Bootstrap #
#############

## Bootstrap application
bootstrap: bootstrap-git bootstrap-docker

bootstrap-git:
	if ! git config remote.upstream.url > /dev/null ; \
		then git remote add upstream git@github.com:1001Pharmacies/docker-pdns-server.git; \
	fi

bootstrap-docker: docker-deploy

## Deploy dockers with docker-compose
docker-deploy:
	if [ ! -f docker-compose.yml ]; \
	then \
	    cp docker-compose.yml.dist docker-compose.yml; \
	fi;
	$(call docker-compose,up -d)

## Start all dockers
start:
	$(call docker-compose,start)

## Stop this project dockers
stop:
	$(call docker-compose,stop)

## Create all dockers
up:
	$(call docker-compose,up -d --no-recreate)

## Kill this project dockers
down:
	$(call docker-compose,down)

# Get a shell inside this project docker
docker-connect:
	$(call docker-compose,exec recursor /bin/sh)

# Install this project
install: bootstrap

##########
# Macros #
##########

ifeq ($(DOCKER), true)
define docker-compose
	docker run --rm $(COMPOSE_ENV) -v /var/run/docker.sock:/var/run/docker.sock -v $$PWD:/$(DOCKER_COMPOSE_PROJECT) -w /$(DOCKER_COMPOSE_PROJECT) docker/compose:1.14.0 $(1)
endef
else
define docker-compose
	$(COMPOSE_ENV) docker-compose $(1)
endef
endif
