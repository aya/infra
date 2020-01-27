##
# UPDATE

.PHONY: update-composer
update-composer: bootstrap
	$(call composer,update)

.PHONY: update-database
update-database: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),app/console --no-interaction doctrine:migration:migrate)

.PHONY: update-npm
update-npm: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),npm upgrade)

