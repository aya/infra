docker-openssl:
	docker run --rm --mount source=node_infra_ssl-certs,target=/certs alpine:latest [ -f /certs/$(SSL_HOSTNAME).crt -a -f /certs/$(SSL_HOSTNAME).key ] \
	  || docker run --rm -e COMMON_NAME=$(SSL_HOSTNAME) -e KEY_NAME=$(SSL_HOSTNAME) --mount source=node_infra_ssl-certs,target=/certs centurylink/openssl:latest

node: docker-openssl node-network node-up

node-%: bootstrap
	DOCKER_NETWORK=node COMPOSE_PROJECT_NAME=node_infra $(MAKE) docker-$* STACK="$(STACK_NODE)" DOCKER_NETWORK=node ARGS=$(ARGS)
