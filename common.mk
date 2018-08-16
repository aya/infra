##
# COMMON

bootstrap: bootstrap-git bootstrap-docker ## Bootstrap application

bootstrap-git:
	if ! git config remote.subrepo/$(SUBREPO).url > /dev/null ; \
		then git remote add subrepo/$(SUBREPO) $(REMOTE); \
	fi

build: docker-build ## Build application dockers images

connect: docker-connect ## Connect to docker $(SERVICE)

down: docker-down ## Remove application dockers

exec: docker-exec ## Exec a command in docker $(SERVICE)

logs: docker-logs ## Display application dockers logs

ps: docker-ps ## List application dockers

rebuild: docker-rebuild ## Rebuild application dockers images

recreate: docker-recreate ## Recreate application dockers

reinstall: clean ## Reinstall application
	$(MAKE) .env
	$(MAKE) install

restart: docker-restart ## Restart application

start: docker-start ## Start application dockers

stop: docker-stop ## Stop application dockers

up: docker-up start-up ## Create application dockers

.DEFAULT:
	echo WARNING: target $@ not available in repo $(SUBREPO). >&2