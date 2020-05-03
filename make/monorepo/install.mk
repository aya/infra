##
# INSTALL

.PHONY: install-$(SHARED)
install-$(SHARED): $(SHARED)

$(SHARED):
	$(ECHO) mkdir -p $(SHARED)
