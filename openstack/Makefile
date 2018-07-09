include ../env.mk
OPENSTACK_ENV=OS_AUTH_URL=$(OS_AUTH_URL) OS_TENANT_ID=$(OS_TENANT_ID) OS_TENANT_NAME=$(OS_TENANT_NAME) OS_USERNAME=$(OS_USERNAME) OS_PASSWORD=$(OS_PASSWORD) OS_REGION_NAME=$(OS_REGION_NAME)
OPENSTACK_ARGS=
ifeq ($(DEBUG), true)
	OPENSTACK_ARGS+= --debug
endif
ifeq ($(ENV), dev)
	OPENSTACK_ARGS+= -v
endif
ifeq ($(DOCKER), true)
	OPENSTACK_ENV:=$(patsubst %,-e %,$(OPENSTACK_ENV))
endif

CMDS := openstack
include ../def.mk
include ../help.mk

.PHONY: help openstack

all: build

openstack:
	$(call openstack,$(ARGS))

image-create:
	$(call openstack,$(OPENSTACK_ARGS) image create --disk-format raw --container-format bare --file ./iso/alpine-3.7.0-x86_64.iso "Alpine 3.7.0")

docker-build: ## Build docker image
	$(MAKE) --directory=.. docker-build DOCKERS=openstack/docker/openstack

build: docker-build

