.PHONY: packer
packer:
	$(call packer,$(ARGS))

.PHONY: packer-build
packer-build: $(PACKER_TEMPLATES) ## Build iso images

.PHONY: $(PACKER_TEMPLATES)
$(PACKER_TEMPLATES): docker-build-packer
	$(call $(MAKECMDGOALS),$@)

.PHONY: packer-build-%
packer-build-%: docker-build-packer
	$(if $(wildcard packer/*/$*.json),$(call packer-build,packer/*/$*.json))
	$(if $(wildcard packer/$*/*.json),$(foreach template,$(wildcard packer/$*/*.json),$(call packer-build,$(template)) && true))

.PHONY: packer-qemu
packer-qemu: $(PACKER_ISOS) ## Launch iso images in qemu

.PHONY: $(PACKER_ISOS)
$(PACKER_ISOS): docker-build-packer
	$(call $(MAKECMDGOALS),$@)

.PHONY: packer-qemu-%
packer-qemu-%: docker-build-packer
	$(if $(wildcard iso/$*/$*.iso),$(call packer-qemu,iso/$*/$*.iso))
