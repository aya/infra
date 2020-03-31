##
# STACK

.PHONY: stack
stack: docker-infra-base docker-infra-images docker-infra-node docker-infra-services
	$(call .env)
	$(eval COMPOSE_FILE:=$(COMPOSE_FILE) docker/docker-compose.yml)
	$(if $(wildcard docker/docker-compose.$(ENV).yml),$(eval COMPOSE_FILE:=$(COMPOSE_FILE) docker/docker-compose.$(ENV).yml))
ifeq ($(MOUNT_NFS),true)
	$(if $(wildcard docker/docker-compose.nfs.yml),$(eval COMPOSE_FILE:=$(COMPOSE_FILE) docker/docker-compose.nfs.yml))
endif
ifeq ($(MOUNT_SSH),true)
	$(if $(wildcard docker/docker-compose.ssh.yml),$(eval COMPOSE_FILE:=$(COMPOSE_FILE) docker/docker-compose.ssh.yml))
endif
ifeq ($(MOUNT_TMPFS),true)
	$(if $(wildcard docker/docker-compose.tmpfs.yml),$(eval COMPOSE_FILE:=$(COMPOSE_FILE) docker/docker-compose.tmpfs.yml))
endif
ifeq ($(SUBREPO),)
	$(if $(wildcard docker/docker-compose.app.yml),$(eval COMPOSE_FILE:=$(COMPOSE_FILE) docker/docker-compose.app.yml))
else
	$(if $(wildcard docker/docker-compose.subrepo.yml),$(eval COMPOSE_FILE:=$(COMPOSE_FILE) docker/docker-compose.subrepo.yml))
endif
