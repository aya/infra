##
# CLEAN

.PHONY: clean-%
clean-%:
	$(call make,docker-compose-down DOCKER_COMPOSE_DOWN_OPTIONS='--rmi all -v' ENV=$*)

.PHONY: clean-env
clean-env:
	rm -i .env || true
