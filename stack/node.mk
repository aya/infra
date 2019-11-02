.PHONY: node
node: node-openssl node-docker-network-create node-up

.PHONY: node-openssl
node-openssl:
	docker run --rm --mount source=$(COMPOSE_PROJECT_NAME_INFRA_NODE)_ssl-certs,target=/certs alpine:latest [ -f /certs/$(SSL_HOSTNAME).crt.pem -a -f /certs/$(SSL_HOSTNAME).key.pem ] \
	 || docker run --rm -e SSL_HOSTNAME=$(SSL_HOSTNAME) --mount source=$(COMPOSE_PROJECT_NAME_INFRA_NODE)_ssl-certs,target=/certs alpine:latest sh -c "apk --no-cache add openssl \
		   && { [ -f /certs/${SSL_HOSTNAME}.key.pem ] || openssl genrsa -out /certs/${SSL_HOSTNAME}.key.pem 2048; } \
	       && openssl req -key /certs/${SSL_HOSTNAME}.key.pem -out /certs/${SSL_HOSTNAME}.crt.pem -addext extendedKeyUsage=serverAuth -addext subjectAltName=DNS:${SSL_HOSTNAME} -subj \"/C=/ST=/L=/O=/CN=${SSL_HOSTNAME}\" -x509 -days 365"

.PHONY: node-%
node-%: bootstrap-infra
ifeq (,$(filter-out $(DOCKER_SERVICES_INFRA_NODE),$(SERVICE)))
	$(eval SERVICE_NODE:=$(SERVICE))
endif
	$(call make,$(patsubst %,-o %,$^) docker-compose-$* COMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME_INFRA_NODE) DOCKER_NETWORK=node SERVICE=$(SERVICE_NODE) STACK="$(STACK_NODE)",,ARGS COMPOSE_IGNORE_ORPHANS ENV)

node-docker-network-create:
	$(call make,$(patsubst %,-o %,$^) docker-network-create DOCKER_NETWORK=node)
