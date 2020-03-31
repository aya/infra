##
# COMMON

.PHONY: bootstrap
bootstrap: bootstrap-git bootstrap-docker ## Bootstrap application

.PHONY: bootstrap-git
bootstrap-git:
ifneq ($(SUBREPO),)
	if ! git config remote.subrepo/$(SUBREPO).url > /dev/null ; \
		then git remote add subrepo/$(SUBREPO) $(GIT_REPOSITORY); \
	fi
endif

.PHONY: build
build: docker-compose-build ## Build application docker images

.PHONY: build-images
build-images: docker-build-images ## Build docker/* images

.PHONY: config
config: docker-compose-config ## View docker compose file

.PHONY: connect
connect: docker-compose-connect ## Connect to docker $(SERVICE)

.PHONY: connect@%
connect@%: SERVICE ?= $(DOCKER_SERVICE)
connect@%: ## Connect to docker $(SERVICE) with ssh on remote ENV $*
	$(eval ENV=$*)
	$(call make,ssh-connect,../infra,SERVER_NAME SERVICE)

.PHONY: down
down: docker-compose-down ## Remove application dockers

.PHONY: exec
exec: ## Exec a command in docker $(SERVICE)
ifneq (,$(filter $(ENV),prod preprod))
	$(call exec,$(ARGS))
else
	$(call make,docker-compose-exec,,ARGS)
endif

.PHONY: exec@%
exec@%: SERVICE ?= $(DOCKER_SERVICE)
exec@%: ## Exec a command in docker $(SERVICE) with ssh on remote ENV $*
	$(eval ENV=$*)
	$(call make,ssh-exec,../infra,ARGS SERVER_NAME SERVICE)

.PHONY: logs
logs: docker-compose-logs ## Display application dockers logs

.PHONY: ps
ps: docker-compose-ps ## List application dockers

.PHONY: rebuild
rebuild: docker-compose-rebuild ## Rebuild application dockers images

.PHONY: rebuild-images
rebuild-images: docker-rebuild-images ## Build docker/* images

.PHONY: recreate
recreate: docker-compose-recreate start-up ## Recreate application dockers

.PHONY: reinstall
reinstall: clean ## Reinstall application
	$(call make,.env)
	$(call make,install)

.PHONY: restart
restart: docker-compose-restart start-up ## Restart application

.PHONY: run
run: ## Run a command
	$(call make,exec -- $(ARGS))

.PHONY: run@%
run@%: ## Run a command on remote server
	$(eval ENV=$*)
	$(call make,ssh-run,../infra,ARGS SERVER_NAME)

.PHONY: scale
scale: docker-compose-scale ## Start application dockers

.PHONY: ssh@%
ssh@%: ## Connect to remote server with ssh
	$(eval ENV=$*)
	$(call make,ssh,../infra,SERVER_NAME)

.PHONY: start
start: docker-compose-start ## Start application dockers

.PHONY: stop
stop: docker-compose-stop ## Stop application dockers

.PHONY: up
up: docker-compose-up start-up ## Create application dockers

.DEFAULT:
	printf "${COLOR_BROWN}WARNING${COLOR_RESET}: ${COLOR_GREEN}target${COLOR_RESET} $@ ${COLOR_GREEN}not available in repo${COLOR_RESET} $(SUBREPO).\n" >&2
