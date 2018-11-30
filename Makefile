include env.mk
include def.mk
include help.mk
include $(filter-out env.mk def.mk $(wildcard def.*.mk) help.mk,$(wildcard *.mk))
include $(wildcard ../subrepo.mk)

.PHONY: $(CMDS) stack-% $(DOCKERS)
ifneq ($(DEBUG), true)
.SILENT:
endif

DOCKERS        := $(dir $(wildcard */docker/*/))

##
# INSTALL

all: install ## Build and deploy infra

install: base node up ## Install docker $(STACK) services

##
# CLEAN

clean: clean-app docker-down clean-env

clean-app:

clean-env:
	rm -i .env || true
	rm -i stack/*/.env || true

##
# BUILD

build: $(DOCKERS)

$(DOCKERS):
	if [ $(DOCKER) = "true" ]; then \
		docker build -t $(lastword $(subst /, ,$@)) $@; \
	fi
