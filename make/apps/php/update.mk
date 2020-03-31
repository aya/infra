##
# UPDATE

.PHONY: update-composer
update-composer: bootstrap
	$(call composer,update)
