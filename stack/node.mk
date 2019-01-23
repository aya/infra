node: node-openssl node-network node-up

node-openssl:
	docker run --rm --mount source=node_infra_ssl-certs,target=/certs alpine:latest [ -f /certs/$(SSL_HOSTNAME).crt -a -f /certs/$(SSL_HOSTNAME).key ] \
	  || docker run --rm -e COMMON_NAME=$(SSL_HOSTNAME) -e KEY_NAME=$(SSL_HOSTNAME) --mount source=node_infra_ssl-certs,target=/certs centurylink/openssl:latest

node-%: bootstrap
ifeq (,$(filter-out $(DOCKER_SERVICE_INFRA_NODE),$(SERVICE)))
	$(eval SERVICE_NODE:=$(SERVICE))
endif
	$(eval MAKE_ARGS := ARGS=$(ARGS) COMPOSE_IGNORE_ORPHANS=$(COMPOSE_IGNORE_ORPHANS) COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME_INFRA_NODE) DOCKER_NETWORK=node ENV=$(ENV))
	$(MAKE_ARGS) $(MAKE) docker-$* $(MAKE_ARGS) SERVICE=$(SERVICE_NODE) STACK="$(STACK_NODE)"
