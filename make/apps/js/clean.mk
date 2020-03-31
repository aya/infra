##
# CLEAN

.PHONY: clean-app
clean-app: clean-assets-deps

.PHONY: clean-assets-deps
clean-assets-deps: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -Rf node_modules/*)
