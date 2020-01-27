.PHONY: clean-%
clean-%:
	$(call make,docker-compose-down DOCKER_COMPOSE_DOWN_OPTIONS="--rmi all -v" ENV=$*)

.PHONY: clean-app
clean-app: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -rf app/bootstrap.php.cache)
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -rf app/cache/* app/cach~)
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -rf app/logs/*)
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -rf var/cache/* var/cach~)
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -rf var/logs/*)
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -rf vendor/*)
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -rf node_modules/*)

.PHONY: clean-assets-deps
clean-assets-deps: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -Rf node_modules/*)

.PHONY: clean-env
clean-env:
	rm -i .env || true

.PHONY: clean-reports
clean-reports: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),rm -Rf reports/*)
