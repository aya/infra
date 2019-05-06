.PHONY: node
node: node-openssl node-docker-network-create node-up

.PHONY: node-openssl
node-openssl:
	docker run --rm --mount source=node_infra_ssl-certs,target=/certs alpine:latest [ -f /certs/$(SSL_HOSTNAME).crt -a -f /certs/$(SSL_HOSTNAME).key ] \
	  || docker run --rm -e COMMON_NAME=$(SSL_HOSTNAME) -e KEY_NAME=$(SSL_HOSTNAME) --mount source=node_infra_ssl-certs,target=/certs centurylink/openssl:latest

.PHONY: node-%
node-%: bootstrap-infra
ifeq (,$(filter-out $(DOCKER_SERVICES_INFRA_NODE),$(SERVICE)))
	$(eval SERVICE_NODE:=$(SERVICE))
endif
	$(call make,$(patsubst %,-o %,$^) docker-compose-$* COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME_INFRA_NODE) DOCKER_NETWORK=node SERVICE=$(SERVICE_NODE) STACK="$(STACK_NODE)",,ARGS COMPOSE_IGNORE_ORPHANS ENV)

node-docker-network-create:
	$(call make,$(patsubst %,-o %,$^) docker-network-create DOCKER_NETWORK=node)
