.PHONY: openstack
openstack:
	$(call openstack,$(ARGS))

.PHONY: openstack-image-create
openstack-image-create: $(PACKER_ISO_FILE)
	$(call openstack,$(OPENSTACK_ARGS) image create --disk-format raw --container-format bare --file $(PACKER_ISO_FILE) "$(PACKER_ISO_NAME)")
