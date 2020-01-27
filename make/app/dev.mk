##
# DEV

## Build assets
.PHONY: dev-assets
dev-assets: ## Build assets
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn build:dev:watch)

.PHONY: dev-outdated
dev-outdated:
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn outdated)

.PHONY: dev-phpcs
dev-phpcs: bootstrap install-phpcs
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/phpcs --standard=PSR2 --colors -p ./src)

.PHONY: dev-phpcbf
dev-phpcbf: bootstrap install-phpcbf
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/phpcbf ./src/ --ignore=*.js)

# compile webpack assets (REACT)
.PHONY: dev-webpack-compile
dev-webpack-compile: bootstrap ## Compile dev assets
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn encore dev)

# watch webpack assets updates (REACT)
.PHONY: dev-webpack-watch
dev-webpack-watch: bootstrap ## Watch dev assets update
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn encore dev --watch)
