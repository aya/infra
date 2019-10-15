.PHONY: packer
packer:
	$(call packer,$(ARGS))

$(PACKER_ISO_FILE):
	$(eval FORCE := true)
	$(call make,packer-build,,FORCE)

.PHONY: packer-build
packer-build: packer-build-$(PACKER_TEMPLATE) ## Build default packer template

.PHONY: packer-build-templates
packer-build-templates: $(PACKER_TEMPLATES) ## Build all packer templates

.PHONY: $(PACKER_TEMPLATES)
$(PACKER_TEMPLATES):
	$(call packer-build,$@)

.PHONY: packer-build-%
packer-build-%: docker-build-packer
	$(if $(wildcard packer/*/$*.json),$(call packer-build,$(wildcard packer/*/$*.json)))

.PHONY: packer-qemu
packer-qemu: packer-qemu-$(PACKER_ISO_NAME) ## Launch iso image in qemu

.PHONY: packer-qemu-%
packer-qemu-%: docker-build-packer ## Run iso image in qemu
	$(if $(wildcard $(PACKER_OUTPUT)/$*.iso),$(call packer-qemu,$(wildcard $(PACKER_OUTPUT)/$*.iso)))
