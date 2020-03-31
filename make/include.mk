MAKE_DIR                        := make
MAKE_FILES                      := env.mk def.mk help.mk
include $(patsubst %,$(MAKE_DIR)/%,$(MAKE_FILES))
include $(foreach subdir,$(MAKE_SUBDIRS),$(filter-out $(wildcard $(MAKE_DIR)/$(subdir)/def.*.mk),$(wildcard $(MAKE_DIR)/$(subdir)/*.mk)))
