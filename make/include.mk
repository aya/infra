MAKE_DIR                        := $(patsubst %/,%,$(dir $(lastword $(MAKEFILE_LIST))))
MAKE_FILES                      := env.mk def.mk help.mk utils.mk
include $(wildcard $(patsubst %,$(MAKE_DIR)/%,$(MAKE_FILES)))
include $(foreach subdir,$(MAKE_SUBDIRS),$(filter-out $(wildcard $(MAKE_DIR)/$(subdir)/def.*.mk),$(wildcard $(MAKE_DIR)/$(subdir)/*.mk)))
include $(wildcard *.mk docker/*.mk stack/*.mk)
