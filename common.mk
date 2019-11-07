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
build: docker-compose-build ## Build application docker images

.PHONY: build-images
build-images: docker-build-images ## Build docker/* images

.PHONY: config
config: docker-compose-config ## View docker compose file

.PHONY: connect
connect: docker-compose-connect ## Connect to docker $(SERVICE)

.PHONY: down
down: docker-compose-down ## Remove application dockers

.PHONY: exec
exec: ## Exec a command in docker $(SERVICE)
ifneq (,$(filter $(ENV),prod preprod))
	$(call exec,$(ARGS))
else
	$(call make,docker-compose-exec ARGS='$(ARGS)')
endif

.PHONY: exec@%
exec@%: ## Exec a command in docker $(SERVICE) with ssh on remote ENV $*
	$(eval ENV=$*)
	$(call make,exec-ssh ENV=$* ARGS='$(ARGS)' SERVER_NAME=$(SERVER_NAME) SERVICE=$(DOCKER_SERVICE),../infra)

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
run: ## Run a command on application servers
ifneq (,$(filter $(ENV),prod preprod))
	$(eval DRYRUN_IGNORE := true)
	$(eval SERVER_LIST := $(shell $(call exec,ssh sshuser@52.50.10.235 make list-nodes |awk "\$$1 ~ /$(OXA_SERVER_NAME)/ {print \$$2}")))
	$(eval DRYRUN_IGNORE := false)
	$(foreach server,$(SERVER_LIST),$(call exec,ssh -Aqtt sshuser@52.50.10.235 "ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no sshuser@$(server) \"sudo -u deploy /bin/bash -c '\''"$(ARGS)"'\''\"" ) &&) true
else
	$(call make,exec -- $(ARGS))
endif

.PHONY: scale
scale: docker-compose-scale ## Start application dockers

.PHONY: start
start: docker-compose-start ## Start application dockers

.PHONY: stop
stop: docker-compose-stop ## Stop application dockers

.PHONY: up
up: docker-compose-up start-up ## Create application dockers

.DEFAULT:
	printf "${COLOR_BROWN}WARNING${COLOR_RESET}: ${COLOR_GREEN}target${COLOR_RESET} $@ ${COLOR_GREEN}not available in repo${COLOR_RESET} $(SUBREPO).\n" >&2
