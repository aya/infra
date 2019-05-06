.PHONY: base
base: docker-network-create base-ssh-add

.PHONY: base-ssh-add
base-ssh-add: base-up
	$(eval SSH_PRIVATE_KEYS := $(foreach file,$(SSH_DIR)/id_rsa $(filter-out $(wildcard $(SSH_DIR)/id_rsa),$(wildcard $(SSH_DIR)/*)),$(if $(shell grep "PRIVATE KEY" $(file) 2>/dev/null),$(notdir $(file)))))
ifneq (,$(filter true,$(DRONE)))
	[ ! -d $(SSH_DIR) ] && mkdir -p $(SSH_DIR) && echo "$$SSH_KEY" > $(SSH_DIR)/drone_id_rsa && chmod 0400 $(SSH_DIR)/drone_id_rsa && chown -R $(UID) $(SSH_DIR) ||:
	$(call docker-run,-v $(DOCKER_INFRA_SSH):/tmp/ssh-agent $(DOCKER_REPO)/$(DOCKER_IMAGE_SSH),ssh-add -l >/dev/null) \
	  || $(call docker-run,-v $(DOCKER_INFRA_SSH):/tmp/ssh-agent $(DOCKER_REPO)/$(DOCKER_IMAGE_SSH),ssh-add $(SSH_DIR)/*_rsa)
else
	$(call docker-run,-v $(DOCKER_INFRA_SSH):/tmp/ssh-agent $(DOCKER_REPO)/$(DOCKER_IMAGE_SSH),ssh-add -l >/dev/null) \
	  || $(call docker-run,-v $(DOCKER_INFRA_SSH):/tmp/ssh-agent -v $(SSH_DIR):/home/$(USER)/.ssh $(DOCKER_REPO)/$(DOCKER_IMAGE_SSH),ssh-add $(patsubst %,/home/$(USER)/.ssh/%,$(SSH_PRIVATE_KEYS)) 2>/dev/null) ||:
endif

.PHONY: base-%
base-%: bootstrap-infra
ifeq (,$(filter-out $(DOCKER_SERVICES_INFRA_BASE),$(SERVICE)))
	$(eval SERVICE_BASE:=$(SERVICE))
endif
	$(call make,$(patsubst %,-o %,$^) docker-compose-$* COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME_INFRA_BASE) SERVICE=$(SERVICE_BASE) STACK="$(STACK_BASE)",,ARGS COMPOSE_IGNORE_ORPHANS DOCKER_NETWORK ENV)

