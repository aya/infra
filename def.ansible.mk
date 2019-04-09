ifeq ($(VERBOSE), true)
ANSIBLE_ARGS                    += -v
endif
ifeq ($(DEBUG), true)
ANSIBLE_ARGS                    += -vvvv
endif
CMDS                            += ansible ansible-playbook

ifeq ($(DOCKER), true)

define ansible
	$(call run,$(DOCKER_SSH_AUTH) $(DOCKER_REPO)/ansible:$(DOCKER_BUILD_TARGET) $(1))
endef
define ansible-playbook
	$(call run,$(DOCKER_SSH_AUTH) --entrypoint /usr/bin/ansible-playbook $(DOCKER_REPO)/ansible:$(DOCKER_BUILD_TARGET) $(1))
endef

else

define ansible
	$(call run,ansible $(1))
endef
define ansible-playbook
	$(call run,ansible-playbook $(1))
endef

endif
