##
# STACK
include stack/*.mk

bootstrap-docker: docker-network setup-sysctl
ifeq ($(SETUP_NFSD),true)
ifeq ($(HOST_SYSTEM),DARWIN)
	$(call setup-nfsd-osx)
endif
endif

setup-sysctl:
ifeq ($(SETUP_SYSCTL),true)
	$(call docker-run,--privileged alpine:latest,/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled')
	$(foreach config,$(SETUP_SYSCTL_CONFIG),$(call docker-run,--privileged alpine:latest,sysctl -w $(config)) >/dev/null &&) true
endif

stack: $(patsubst %,stack-%,$(STACK)) bootstrap
	$(call .env)

stack-%: ## Start docker stack
	$(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.yml)
	$(if $(wildcard stack/$*/docker-compose.$(ENV).yml), $(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*/docker-compose.$(ENV).yml))
	$(if $(wildcard stack/$*/.env.dist), $(call .env,stack/$*) $(eval ENV_FILE:=$(ENV_FILE) stack/$*/.env))

start-up: base-ssh-add

define setup-nfsd-osx
	$(eval dir:=$(or $(1),$(MONOREPO_DIR)))
	$(eval uid:=$(or $(2),$(UID)))
	$(eval gid:=$(or $(3),$(GID)))
	grep "$(dir)" /etc/exports >/dev/null 2>&1 || echo "$(dir) -alldirs -mapall=$(uid):$(gid) localhost" |sudo tee -a /etc/exports >/dev/null
	$(foreach config,$(SETUP_NFSD_OSX_CONFIG),grep "$(config)" /etc/nfs.conf >/dev/null 2>&1 || echo "$(config)" |sudo tee -a /etc/nfs.conf >/dev/null &&) true
	nfsd status >/dev/null || sudo nfsd enable
	showmount -e localhost |grep "$(dir)" >/dev/null 2>&1 || sudo nfsd restart
endef
