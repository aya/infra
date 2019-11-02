##
# STACK
include stack/*.mk

.PHONY: bootstrap-infra
bootstrap-infra: bootstrap

.PHONY: bootstrap-docker
bootstrap-docker: docker-network-create setup-sysctl
ifeq ($(SETUP_NFSD),true)
ifeq ($(HOST_SYSTEM),DARWIN)
	$(call setup-nfsd-osx)
endif
endif

.PHONY: setup-sysctl
setup-sysctl:
ifeq ($(SETUP_SYSCTL),true)
	$(call docker-run,--privileged alpine:latest,/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled ||:' >/dev/null)
	$(foreach config,$(SETUP_SYSCTL_CONFIG),$(call docker-run,--privileged alpine:latest,sysctl -q -w $(config)) &&) true
endif

.PHONY: stack
stack: $(patsubst %,stack-%,$(STACK)) bootstrap-infra
	$(call .env)

.PHONY: stack-%
stack-%: ## Start docker stack
	$(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.yml)
	$(if $(wildcard stack/$*/docker-compose.$(ENV).yml), $(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.$(ENV).yml))
	$(if $(wildcard stack/$*/.env.dist), $(call .env,stack/$*) $(eval ENV_FILE:=$(ENV_FILE) stack/$*/.env))

.PHONY: start-up
start-up: base-ssh-add
