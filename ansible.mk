.PHONY: ansible
ansible: docker-build-ansible
	$(call ansible,$(ANSIBLE_ARGS) $(ARGS))

.PHONY: ansible-playbook
ansible-playbook:
	$(call ansible-playbook,$(ANSIBLE_ARGS) $(ARGS))

.PHONY: ansible-pull
ansible-pull:
	$(call ansible-pull,--url $(ANSIBLE_GIT_REPOSITORY) $(if $(ANSIBLE_GIT_KEY_FILE),--key-file $(ANSIBLE_GIT_KEY_FILE)) $(if $(ANSIBLE_GIT_VERSION),--checkout $(ANSIBLE_GIT_VERSION)) $(if $(ANSIBLE_GIT_DIRECTORY),--directory $(ANSIBLE_GIT_DIRECTORY)) $(if $(ANSIBLE_TAGS),--tags $(ANSIBLE_TAGS)) $(if $(ANSIBLE_EXTRA_VARS),--extra-vars '$(ANSIBLE_EXTRA_VARS)') $(if $(findstring true,$(FORCE)),--force) $(if $(findstring true,$(DRYRUN)),--check) --full $(if $(ANSIBLE_INVENTORY),--inventory $(ANSIBLE_INVENTORY)) $(ANSIBLE_PLAYBOOK))

.PHONY: ansible-run
ansible-run: ansible-run-localhost

.PHONY: ansible-run-%
ansible-run-%:
	$(call ansible-playbook,$(if $(ANSIBLE_TAGS),--tags $(ANSIBLE_TAGS)) $(if $(ANSIBLE_EXTRA_VARS),--extra-vars '$(patsubst target=localhost,target=$*,$(ANSIBLE_EXTRA_VARS))') $(if $(findstring true,$(DRYRUN)),--check) $(if $(ANSIBLE_INVENTORY),--inventory $(patsubst infra/%,%,$(ANSIBLE_INVENTORY))) $(patsubst infra/%,%,$(ANSIBLE_PLAYBOOK)))
