## Load .env
include ../../env.mk
include ../../def.mk
include ../../help.mk
include ../stack.mk

.PHONY: bootstrap install start stop tests

##
# BOOTSTRAP

bootstrap: bootstrap-docker ## Bootstrap docker stack

bootstrap-docker: docker-network

##
# INSTALL

install: bootstrap start ## Install docker stack

## Post start scripts
start-up: up

