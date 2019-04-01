ENV_SYSTEM                      += OS_AUTH_URL=$(OS_AUTH_URL) OS_TENANT_ID=$(OS_TENANT_ID) OS_TENANT_NAME=$(OS_TENANT_NAME) OS_USERNAME=$(OS_USERNAME) OS_PASSWORD=$(OS_PASSWORD) OS_REGION_NAME=$(OS_REGION_NAME)
OPENSTACK_ARGS                  ?=
ifeq ($(DEBUG), true)
OPENSTACK_ARGS                  += --debug
endif
ifeq ($(ENV), dev)
OPENSTACK_ARGS                  += -v
endif

.PHONY: openstack
openstack:
	$(call openstack,$(ARGS))

.PHONY: image-create
image-create:
	$(call openstack,$(OPENSTACK_ARGS) image create --disk-format raw --container-format bare --file ./iso/alpine-3.7.0-x86_64.iso "Alpine 3.7.0")
