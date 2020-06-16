##
# CLEAN

.PHONY: clean
clean:
ifneq (,$(filter $(ENV),$(ENV_DEPLOY)))
	$(call make,clean-$(ENV))
else
	$(call make,clean-app docker-compose-down clean-env)
endif

.PHONY: clean-%
clean-%:
	$(call make,docker-compose-down DOCKER_COMPOSE_DOWN_OPTIONS='--rmi all -v')

.PHONY: clean-env
clean-env:
	rm -i .env || true
