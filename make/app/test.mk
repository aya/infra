##
# TEST

## Run unit tests
.PHONY: test
test: test-unit ## Run unit tests

.PHONY: test-assets
test-assets: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn test)

## Run codeception tests
.PHONY: test-codeception-%
test-codeception-%: bootstrap install-codecept ## Run codeception tests
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/codecept run $*)

## Run old unit tests with code coverage
.PHONY: test-coverage
test-coverage: bootstrap install-phpunit ## Run code coverage
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/phpunit --testsuite unit --coverage-text)

## Run codeception tests with coverage
.PHONY: test-coverage-codeception-%
test-coverage-codeception-%: bootstrap install-codecept ## Run codeception tests with coverage
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/codecept run $* --coverage --coverage-html)

## Run phpunit functional tests
.PHONY: test-func
test-func: bootstrap install-phpunit ## Run functional tests
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/phpunit --testsuite functional)

## Run functional tests (make test-func TEST="S01-U1-find-product")
.PHONY: test-func-js
test-func-js: bootstrap ## Run functional tests (js)
ifdef TEST
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn test:func -- --test tests/Functional/specs/$(TEST).js --env $(TESTENV))
else ifdef TESTSUITE
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn test:func -- --tag $(TESTSUITE) --env $(TESTENV))
else
	$(call docker-compose-exec,$(DOCKER_SERVICE),yarn test:func -- --env $(TESTENV))
endif

## Loop unit tests
.PHONY: test-loop
test-loop: bootstrap install-phpunit ## Loop unit tests
	while true; \
		do $(MAKE) test; \
		read continue; \
	done;

## Run search tests
.PHONY: test-search
test-search: bootstrap install-phpunit ## Run search tests
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/phpunit --testsuite search)

.PHONY: test-templates
test-templates: bootstrap
	$(call docker-compose-exec,$(DOCKER_SERVICE),php app/console lint:twig @UIBundle)

## Run old unit tests
.PHONY: test-unit
test-unit: bootstrap install-phpunit ## Run unit tests
ifdef FILTER
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/phpunit --testsuite unit --filter $(FILTER))
else
	$(call docker-compose-exec,$(DOCKER_SERVICE),bin/phpunit --testsuite unit)
endif
