docker-openssl:
	docker run --rm --mount source=$(COMPOSE_PROJECT_NAME)_ssl-certs,target=/certs alpine:latest [ -f /certs/$(SSL_HOSTNAME).crt -a -f /certs/$(SSL_HOSTNAME).key ] \
	  || docker run --rm -e COMMON_NAME=$(SSL_HOSTNAME) -e KEY_NAME=$(SSL_HOSTNAME) --mount source=$(COMPOSE_PROJECT_NAME)_ssl-certs,target=/certs centurylink/openssl:latest

docker-network-connect:
	for network in $(DOCKER_NODE_NETWORK); do \
		if [ $$(docker network ls -q --filter name='^'$${network}'$$' |wc -l) -gt 0 ]; then \
			docker ps -q --no-trunc --filter name=node_infra_ |while read docker; do docker inspect $${network} |grep $${docker} >/dev/null 2>&1 || docker network connect $${network} $${docker}; done \
		fi; \
	done

