##
# DOCKER

docker-build: stack
	$(call docker-compose,build --pull)

docker-down: stack
	$(call docker-compose,down)

docker-down-rm: stack
	$(call docker-compose,down --rmi local -v)

docker-connect: SERVICE ?= $(DOCKER_SERVICE)
docker-connect: stack docker-up
	$(call docker-compose,exec $(SERVICE) /bin/bash || true)

docker-exec: SERVICE ?= $(DOCKER_SERVICE)
docker-exec: stack docker-up
	$(call docker-compose-exec,$(SERVICE),$(ARGS) || true)

docker-logs: stack docker-up
	$(call docker-compose,logs -f --tail=100 $(SERVICE) || true)

docker-network:
	[ -n "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Creating docker network $(DOCKER_NETWORK) ... " && docker network create $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }
	docker ps -q --no-trunc --filter name=node_infra_ |while read docker; do docker inspect $(DOCKER_NETWORK) |grep $${docker} >/dev/null 2>&1 || docker network connect $(DOCKER_NETWORK) $${docker}; done

docker-network-rm:
	[ -z "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Removing docker network $(DOCKER_NETWORK) ... " && docker network rm $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

docker-ps: stack
	$(call docker-compose,ps)

docker-rebuild: stack
	$(call docker-compose,build --pull --no-cache)

docker-recreate: stack docker-down docker-up

docker-restart: stack
	$(call docker-compose,restart)

docker-services:
ifneq (,$(filter $(MAKECMDGOALS),install ps start up))
	ENV=$(ENV) $(MAKE) -C ../infra $(MAKECMDGOALS) STACK=services || true
endif

docker-start: stack
	$(call docker-compose,start)

docker-stop: stack
	$(call docker-compose,stop)

docker-up: stack
	$(call docker-compose,up -d)
