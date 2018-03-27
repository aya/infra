##
# REINSTALL

## Force remove docker services
clean:
	down

## Reinstall application
reinstall: recreate

##
# DOCKER

docker-network:
	[ -n "$(shell docker network ls -q --filter name='^$(DOCKER_NETWORK)$$' 2>/dev/null)" ] \
	  || { echo -n "Creating docker network $(DOCKER_NETWORK) ... " && docker network create $(DOCKER_NETWORK) >/dev/null 2>&1 && echo "done" || echo "ERROR"; }

docker-up: bootstrap
	$(call docker-compose,up -d)

docker-start: bootstrap
	$(call docker-compose,start)

docker-stop:
	$(call docker-compose,stop)

docker-down:
	$(call docker-compose,down)

##
# START

## Create docker services
up: docker-up ## Create docker stack

## Remove docker services
down: docker-down ## Remove docker stack

## Recreate docker services
recreate: down start-up ## Recreate docker stack

## Start docker services
start: up start-up ## Start docker stack

## Stop docker services
stop: docker-stop ## Stop docker stack

## Restart docker services
restart: stop start ## Restart docker stack

