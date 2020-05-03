##
# COMMON

.PHONY: bootstrap
bootstrap: bootstrap-git bootstrap-docker ## Bootstrap application

.PHONY: boostrap-docker
bootstrap-docker: docker-network-create
	$(if $(filter bootstrap-$(APP),$(MAKETARGETS)),$(call make,bootstrap-$(APP)))
	$(call make,docker-compose-up)

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

.PHONY: config@%
config@%:
	$(eval ENV=$*)
	$(call make,docker-compose-config)

.PHONY: connect
connect: docker-compose-connect ## Connect to docker $(SERVICE)

.PHONY: connect@%
connect@%: SERVICE ?= $(DOCKER_SERVICE)
connect@%: ## Connect to docker $(SERVICE) with ssh on remote ENV $*
	$(eval ENV=$*)
	$(call make,ssh-connect,../infra,SERVICE)

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
	$(call make,ssh-exec,../infra,ARGS SERVICE)

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
	$(call make,ssh-run,../infra,ARGS)

.PHONY: scale
scale: docker-compose-scale ## Start application dockers

.PHONY: ssh@%
ssh@%: ## Connect to remote server with ssh
	$(eval ENV=$*)
	$(call make,ssh,../infra)

.PHONY: stack
stack: $(patsubst %,stack-%,$(STACK))

.PHONY: stack-%
stack-%:
	$(eval stack   := $(subst -$(lastword $(subst -, ,$*)),,$*))
	$(eval command := $(lastword $(subst -, ,$*)))
	$(if $(findstring -,$*), \
	  $(if $(filter $(command),$(filter-out %-%,$(patsubst docker-compose-%,%,$(filter docker-compose-%,$(MAKETARGETS))))), \
	    $(call make,docker-compose-$(command) STACK="$(stack)" $(if $(filter node,$(stack)),COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME_INFRA_NODE)),,ARGS COMPOSE_IGNORE_ORPHANS SERVICE)), \
	  $(call docker-stack,$*,))

.PHONY: start
start: docker-compose-start ## Start application dockers

.PHONY: stop
stop: docker-compose-stop ## Stop application dockers

.PHONY: up
up: docker-compose-up start-up ## Create application dockers

##
# % target
# this target is fired everytime make is runned, to hydrate the COMPOSE_FILE
# variable with all the .yml files of the current project stack
.PHONY: FORCE
%: FORCE stack %-rule-exists ;

##
# %-rule-exists target
# this target is fired to print a warning message if the $* target does not exists
%-rule-exists:
	$(if $(filter $*,$(MAKECMDGOALS)),$(if $(filter-out $*,$(MAKETARGETS)),printf "${COLOR_BROWN}WARNING${COLOR_RESET}: ${COLOR_GREEN}target${COLOR_RESET} $* ${COLOR_GREEN}not available in${COLOR_RESET} $(APP).\n" >&2))
