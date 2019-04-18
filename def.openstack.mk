ENV_SYSTEM_VARS                 += OS_AUTH_URL OS_TENANT_ID OS_TENANT_NAME OS_USERNAME OS_PASSWORD OS_REGION_NAME
ifeq ($(DEBUG), true)
OPENSTACK_ARGS                  += --debug
endif
ifeq ($(ENV), local)
OPENSTACK_ARGS                  += -v
endif

ifeq ($(DOCKER), true)
define openstack
	$(call run,$(DOCKER_SSH_AUTH) $(DOCKER_REPO)/openstack:$(DOCKER_BUILD_TARGET) $(1))
endef
else
define openstack
	$(call run,openstack $(1))
endef
endif
