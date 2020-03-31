##
# INSTALL

.PHONY: install-parameters
install-parameters:
	$(call install-parameters)

.PHONY: install-parameters-%
install-parameters-%:
	$(call install-parameters,$*)
