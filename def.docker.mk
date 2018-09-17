COMPOSE_VERSION                 ?= 1.22.0
COMPOSE_PROJECT_NAME            ?= $(ENV)_$(APP)
DOCKER                          ?= true
DOCKER_BUILD_TARGET             ?= local
DOCKER_NETWORK                  ?= $(ENV)

ifeq ($(DRONE), true)
define docker-run
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -v $$(docker inspect $$(hostname) |awk 'BEGIN {FS=":"} $$0 ~ /_default:\/drone/ {gsub(/^[ \t\r\n]*"/,"",$$1); print $$1; exit}'):/drone -w $$PWD $(1) $(2)
endef
define docker-compose
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -v /var/run/docker.sock:/var/run/docker.sock -v $$(docker inspect $$(hostname) |awk 'BEGIN {FS=":"} $$0 ~ /_default:\/drone/ {gsub(/^[ \t\r\n]*"/,"",$$1); print $$1; exit}'):/drone -w $$PWD docker/compose:$(COMPOSE_VERSION) $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -v /var/run/docker.sock:/var/run/docker.sock -v $$(docker inspect $$(hostname) |awk 'BEGIN {FS=":"} $$0 ~ /_default:\/drone/ {gsub(/^[ \t\r\n]*"/,"",$$1); print $$1; exit}'):/drone -w $$PWD docker/compose:$(COMPOSE_VERSION) $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) exec -T $(1) sh -c '$(2)'
endef
else ifeq ($(DOCKER), true)
define docker-run
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -it -v $$PWD:$$PWD -w $$PWD $(1) $(2)
endef
define docker-compose
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v $$PWD:$$PWD -w $$PWD docker/compose:$(COMPOSE_VERSION) $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -it -v /var/run/docker.sock:/var/run/docker.sock -v $$PWD:$$PWD -w $$PWD docker/compose:$(COMPOSE_VERSION) $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) exec $(1) sh -c '$(2)'
endef
else
SHELL := /bin/bash
define docker-run
	docker run $(ENV_SYSTEM) $(ENV_FILE) --rm -it -v $$PWD:$$PWD -w $$PWD $(1) $(2)
endef
define docker-compose
	IFS=$$'\n'; env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '!seen[$$1]++') docker-compose $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) $(1)
endef
define docker-compose-exec
	IFS=$$'\n'; env $(ENV_SYSTEM) $$(cat $(ENV_FILE) 2>/dev/null |awk -F "=" '!seen[$$1]++') docker-compose $(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) exec $(1) sh -c '$(2)'
endef
endif
