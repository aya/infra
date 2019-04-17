.PHONY: packer
packer:
	$(call packer,$(ARGS))

.PHONY: packer-build
packer-build: packer-build-$(PACKER_TEMPLATE) ## Build default packer template

.PHONY: packer-build-templates
packer-build-templates: $(PACKER_TEMPLATES) ## Build all packer templates

.PHONY: $(PACKER_TEMPLATES)
$(PACKER_TEMPLATES): docker-build-packer
	$(call $(MAKECMDGOALS),$@)

.PHONY: packer-build-%
packer-build-%: docker-build-packer
	$(if $(wildcard packer/*/$*.json),$(call packer-build,$(wildcard packer/*/$*.json)))
#	$(if $(wildcard packer/$*/*.json),$(foreach template,$(wildcard packer/$*/*.json),$(call packer-build,$(template)) && true))

.PHONY: packer-qemu
packer-qemu: packer-qemu-$(PACKER_ISO_NAME) ## Launch iso image in qemu

.PHONY: packer-qemu-%
packer-qemu-%: docker-build-packer ## Run iso image in qemu
	$(if $(wildcard iso/*/$*.iso),$(call packer-qemu,$(wildcard iso/*/$*.iso)))
