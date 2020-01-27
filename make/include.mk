INCLUDE_DIR                     := make
INCLUDE_FILES                   := env.mk def.mk help.mk
include $(patsubst %,$(INCLUDE_DIR)/%,$(INCLUDE_FILES))
include $(foreach subdir,$(INCLUDE_SUBDIRS),$(filter-out $(wildcard $(INCLUDE_DIR)/$(subdir)/def.*.mk),$(wildcard $(INCLUDE_DIR)/$(subdir)/*.mk)))
