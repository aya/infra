.PHONY: ansible
ansible: docker-build-ansible
	$(call ansible,$(ANSIBLE_ARGS) $(ARGS))

.PHONY: ansible-playbook
ansible-playbook: docker-build-ansible
	$(call ansible-playbook,$(ANSIBLE_ARGS) $(ARGS))
