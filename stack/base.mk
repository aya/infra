.PHONY: base
base: docker-network-create stack-base-up base-ssh-add

.PHONY: ssh-add
ssh-add: base-ssh-add

.PHONY: base-ssh-add
base-ssh-add: base-ssh-key
	$(eval SSH_PRIVATE_KEYS := $(foreach file,$(SSH_DIR)/id_rsa $(filter-out $(wildcard $(SSH_DIR)/id_rsa),$(wildcard $(SSH_DIR)/*)),$(if $(shell grep "PRIVATE KEY" $(file) 2>/dev/null),$(notdir $(file)))))
	$(call docker-run,-v $(DOCKER_VOLUME_SSH):/tmp/ssh-agent $(DOCKER_IMAGE_SSH),ssh-add -l >/dev/null) \
	  || $(call docker-run,-v $(DOCKER_VOLUME_SSH):/tmp/ssh-agent $(DOCKER_IMAGE_SSH),ssh-add $(patsubst %,$(SSH_DIR)/%,$(SSH_PRIVATE_KEYS)) 2>/dev/null) ||:

.PHONY: base-ssh-key
base-ssh-key: stack-base-up
ifneq (,$(filter true,$(DRONE)))
	$(call exec,[ ! -d $(SSH_DIR) ] && mkdir -p $(SSH_DIR) && chown $(UID) $(SSH_DIR) && chmod 0700 $(SSH_DIR) ||:)
else
	$(eval DOCKER_RUN_VOLUME += -v $(SSH_DIR):$(SSH_DIR))
endif
	$(if $(SSH_KEY),$(eval export SSH_KEY ?= $(SSH_KEY)) $(call docker-run,$(DOCKER_IMAGE_CLI),echo -e "$$SSH_KEY" > $(SSH_DIR)/${COMPOSE_PROJECT_NAME}_id_rsa && chmod 0400 $(SSH_DIR)/${COMPOSE_PROJECT_NAME}_id_rsa && chown $(UID) $(SSH_DIR)/${COMPOSE_PROJECT_NAME}_id_rsa ||:))
