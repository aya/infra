##
# COMMON

.PHONY: bootstrap
bootstrap: bootstrap-git bootstrap-docker ## Bootstrap application

.PHONY: bootstrap-git
bootstrap-git:
	if ! git config remote.subrepo/$(SUBREPO).url > /dev/null ; \
		then git remote add subrepo/$(SUBREPO) $(REMOTE); \
	fi

.PHONY: build
build: docker-build ## Build application dockers images

.PHONY: config
config: docker-config ## View docker compose file

.PHONY: connect
connect: docker-connect ## Connect to docker $(SERVICE)

.PHONY: down
down: docker-down ## Remove application dockers

.PHONY: exec
exec: docker-exec ## Exec a command in docker $(SERVICE)

.PHONY: logs
logs: docker-logs ## Display application dockers logs

.PHONY: ps
ps: docker-ps ## List application dockers

.PHONY: rebuild
rebuild: docker-rebuild ## Rebuild application dockers images

.PHONY: recreate
recreate: docker-recreate start-up ## Recreate application dockers

.PHONY: reinstall
reinstall: clean ## Reinstall application
	$(MAKE) .env
	$(MAKE) install

.PHONY: restart
restart: docker-restart start-up ## Restart application

.PHONY: start
start: docker-start ## Start application dockers

.PHONY: stop
stop: docker-stop ## Stop application dockers

.PHONY: up
up: docker-up start-up ## Create application dockers

.DEFAULT:
	printf "${COLOR_BROWN}WARNING${COLOR_RESET}: ${COLOR_GREEN}target${COLOR_RESET} $@ ${COLOR_GREEN}not available in repo${COLOR_RESET} $(SUBREPO).\n" >&2
