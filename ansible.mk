ifeq ($(VERBOSE), true)
ANSIBLE_ARGS                    += -v
endif
ifeq ($(DEBUG), true)
ANSIBLE_ARGS                    += -vvvv
endif
ANSIBLE_ENV                     :=
CMDS                            += ansible ansible-playbook

.PHONY: ansible
ansible:
	$(call ansible, $(ANSIBLE_ARGS) $(ARGS))

.PHONY: ansible-playbook
ansible-playbook:
	$(call ansible-playbook, $(ANSIBLE_ARGS) $(ARGS))
