base: docker-network base-ssh-add

base-ssh-add: base-up
ifneq (,$(filter true,$(DRONE)))
	[ ! -d $(SSH_DIR) ] && mkdir -p $(SSH_DIR) && echo "$$SSH_KEY" > $(SSH_DIR)/drone_id_rsa && chmod 0400 $(SSH_DIR)/drone_id_rsa && chown -R $(UID) $(SSH_DIR) ||:
	$(call docker-run,-v $(COMPOSE_PROJECT_NAME)_ssh-agent:/tmp/ssh-agent $(DOCKER_IMAGE_REPO)/$(DOCKER_IMAGE_SSH):$(DOCKER_IMAGE_TAG),ssh-add -l >/dev/null) \
	  || $(call docker-run,-v $(COMPOSE_PROJECT_NAME)_ssh-agent:/tmp/ssh-agent $(DOCKER_IMAGE_REPO)/$(DOCKER_IMAGE_SSH):$(DOCKER_IMAGE_TAG),ssh-add $(SSH_DIR)/*_rsa)
else
	$(call docker-run,-v $(ENV)_$(subst /,_,$(DOCKER_IMAGE_SSH)):/tmp/ssh-agent $(DOCKER_IMAGE_REPO)/$(DOCKER_IMAGE_SSH):$(DOCKER_IMAGE_TAG),ssh-add -l >/dev/null) \
	  || $(call docker-run,-v $(ENV)_$(subst /,_,$(DOCKER_IMAGE_SSH)):/tmp/ssh-agent -v $(SSH_DIR):/home/$(USER)/.ssh $(DOCKER_IMAGE_REPO)/$(DOCKER_IMAGE_SSH):$(DOCKER_IMAGE_TAG),ssh-add /home/$(USER)/.ssh/*_rsa)
endif

base-%: bootstrap
ifeq (,$(filter-out exec ssh-agent,$(SERVICE)))
	$(eval SERVICE_BASE:=$(SERVICE))
endif
	COMPOSE_IGNORE_ORPHANS=$(COMPOSE_IGNORE_ORPHANS) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) COMPOSE_SERVICE_NAME=$(COMPOSE_SERVICE_NAME) DOCKER_NETWORK=$(DOCKER_NETWORK) ENV=$(ENV) $(MAKE) docker-$* STACK="$(STACK_BASE)" DOCKER_NETWORK=$(DOCKER_NETWORK) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME) COMPOSE_SERVICE_NAME=$(COMPOSE_SERVICE_NAME) SERVICE=$(SERVICE_BASE) ARGS=$(ARGS)
