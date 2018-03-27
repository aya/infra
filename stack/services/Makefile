## Load .env
include ../../env.mk
include ../../def.mk
include ../../help.mk
include ../stack.mk

.PHONY: bootstrap install start stop tests

##
# BOOTSTRAP

bootstrap: bootstrap-docker ## Bootstrap docker stack

bootstrap-docker: docker-network docker-elasticsearch docker-openssl

docker-elasticsearch:
	docker run --rm --privileged alpine:latest sysctl -w vm.max_map_count=$(SYSCTL_VM_MAX_MAP_COUNT) >/dev/null

docker-openssl:
	docker run --rm --mount source=$(DOCKER_NETWORK)_ssl-certs,target=/certs alpine:latest [ -f /certs/$(SSL_HOSTNAME).crt -a -f /certs/$(SSL_HOSTNAME).key ] \
	  || docker run --rm -e COMMON_NAME=$(SSL_HOSTNAME) -e KEY_NAME=$(SSL_HOSTNAME) --mount source=$(DOCKER_NETWORK)_ssl-certs,target=/certs centurylink/openssl:latest

##
# INSTALL

install: bootstrap start ## Install docker stack

## Post start scripts
start-up: up ssh-add

## Load your ssh private key in the ssh-agent docker
ssh-add:
	docker run --rm --mount source=$(DOCKER_NETWORK)_ssh-agent,target=/tmp/ssh-agent 1001pharmadev/ssh-agent:latest ssh-add -l >/dev/null \
		|| docker run --rm --mount source=$(DOCKER_NETWORK)_ssh-agent,target=/tmp/ssh-agent -v $(SSH_PRIVATE_KEY):/root/.ssh/id_rsa -it 1001pharmadev/ssh-agent:latest ssh-add /root/.ssh/id_rsa

