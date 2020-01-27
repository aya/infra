comma                           ?= ,
dollar                          ?= $
dquote                          ?= "
quote                           ?= '
APP                             ?= $(if $(wildcard .git),,$(SUBREPO))
BRANCH                          ?= $(shell git rev-parse --abbrev-ref HEAD)
CMDS                            ?= exec exec@% run
COMMIT                          ?= $(shell git rev-parse $(BRANCH) 2>/dev/null)
CONTEXT                         ?= $(shell awk 'BEGIN {FS="="}; $$1 !~ /^(\#|$$)/ {print $$1}' .env.dist 2>/dev/null) BRANCH UID USER VERSION
DEBUG                           ?= false
DOCKER                          ?= true
DRONE                           ?= false
DRYRUN                          ?= false
DRYRUN_IGNORE                   ?= false
DRYRUN_RECURSIVE                ?= false
ENV                             ?= local
ENV_FILE                        ?= .env
ENV_RESET                       ?= false
ENV_VARS                        ?= APP BRANCH ENV HOSTNAME GID MONOREPO MONOREPO_DIR SUBREPO_DIR TAG UID USER VERSION
GID                             ?= $(shell id -g)
HOSTNAME                        ?= $(shell hostname |sed 's/\..*//')
MAKE_ARGS                       ?= $(foreach var,$(MAKE_VARS),$(if $($(var)),$(var)='$($(var))'))
MAKE_VARS                       ?= ENV
MONOREPO                        ?= $(if $(wildcard .git),$(notdir $(CURDIR)),$(notdir $(realpath $(CURDIR)/..)))
MONOREPO_DIR                    ?= $(if $(wildcard .git),$(CURDIR),$(realpath $(CURDIR)/..))
RECURSIVE                       ?= true
SUBREPO                         ?= $(if $(wildcard .git),,$(notdir $(CURDIR)))
SUBREPO_DIR                     ?= $(if $(wildcard .git),,$(CURDIR))
SUBREPO_COMMIT                  ?= $(if $(wildcard .git),,$(shell git rev-parse subrepo/$(SUBREPO)/$(BRANCH) 2>/dev/null))
TAG                             ?= $(shell git tag -l --points-at $(BRANCH) 2>/dev/null)
UID                             ?= $(shell id -u)
USER                            ?= $(shell id -nu)
VERBOSE                         ?= true
VERSION                         ?= $(shell git describe --tags $(BRANCH) 2>/dev/null || git rev-parse $(BRANCH) 2>/dev/null)

ifeq ($(DOCKER), true)
ENV_ARGS                         = $(foreach var,$(ENV_VARS),$(if $($(var)),-e $(var)='$($(var))')) $(shell printenv |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } ($$1 in A) {print "-e "$$0}' .env.dist - 2>/dev/null)
else
ENV_ARGS                         = $(foreach var,$(ENV_VARS),$(if $($(var)),$(var)='$($(var))')) $(shell printenv |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } ($$1 in A)' .env.dist - 2>/dev/null)
endif

# Guess OS
ifeq ($(OSTYPE),cygwin)
HOST_SYSTEM                     := CYGWIN
else ifeq ($(OS),Windows_NT)
HOST_SYSTEM                     := WINDOWS
else
UNAME_S := $(shell uname -s 2>/dev/null)
ifeq ($(UNAME_S),Linux)
HOST_SYSTEM                     := LINUX
endif
ifeq ($(UNAME_S),Darwin)
HOST_SYSTEM                     := DARWIN
endif
endif

ifneq ($(DEBUG), true)
.SILENT:
endif
ifeq ($(DRYRUN), true)
ECHO                             = $(if $(filter $(DRYRUN_IGNORE),true),,printf "${COLOR_BROWN}$(APP)${COLOR_RESET}[${COLOR_GREEN}$(MAKELEVEL)${COLOR_RESET}] ${COLOR_BLUE}$@${COLOR_RESET}:${COLOR_RESET} "; echo)
ifeq ($(RECURSIVE), true)
DRYRUN_RECURSIVE                := true
endif
endif

ifeq ($(HOST_SYSTEM),DARWIN)
define getent-group
$(shell dscl . -read /Groups/$(1) 2>/dev/null |awk '$$1 == "PrimaryGroupID:" {print $$2}')
endef
ifneq ($(DOCKER),true)
SED_SUFFIX='\'\''
endif
else
define getent-group
$(shell getent group $(1) 2>/dev/null |awk -F: '{print $$3}')
endef
endif

define conf
	$(eval file := $(1))
	$(eval block := $(2))
	$(eval variable := $(3))
	[ -r "$(file)" ] && while IFS='=' read -r key value; do \
		case $${key} in \
		  \#*) \
			continue; \
			;; \
		  \[*\]) \
			current_bloc="$${key##\[}"; \
			current_bloc="$${current_bloc%%\]}"; \
			[ -z "$(block)" ] && [ -z "$(variable)" ] && printf '%s\n' "$${current_bloc}" ||:; \
			;; \
		  *) \
			key=$${key%$${key##*[![:space:]]}}; \
			value=$${value#$${value%%[![:space:]]*}}; \
			if [ "$(block)" = "$${current_bloc}" ] && [ "$${key}" ]; then \
				[ -z "$(variable)" ] && printf '%s=%s\n' "$${key}" "$${value}" ||:; \
				[ "$(variable)" = "$${key}" ] && printf '%s\n' "$${value}" ||:; \
			fi \
			;; \
		esac \
	done < "$(file)" || echo "Unable to read $(file)" >&2
endef

define sed
$(call exec,sed -i $(SED_SUFFIX) '\''$(1)'\'' $(2))
endef

define make
	$(eval cmd := $(1))
	$(eval dir := $(2))
	$(eval env := $(or $(3),$(MAKE_VARS)))
	$(eval MAKE_ARGS := $(or $(4),$(if $(env),$(foreach var,$(env),$(if $($(var)),$(var)='$($(var))')))))
	$(eval MAKE_DIR := $(if $(dir),-C $(dir)))
	$(eval MAKE_OLDFILE := $(MAKE_OLDFILE) $(filter-out $(MAKE_OLDFILE), $^))
	$(if $(filter $(VERBOSE),true),printf "${COLOR_GREEN}Running${COLOR_RESET} make $(cmd) $(if $(dir),${COLOR_BLUE}in folder${COLOR_RESET} $(dir) )${COLOR_GREEN}with${COLOR_RESET} $(MAKE_ARGS)\n")
	$(ECHO) $(MAKE_ARGS) $(MAKE) $(MAKE_DIR) $(patsubst %,-o %,$(MAKE_OLDFILE)) $(cmd) MAKE_OLDFILE="$(MAKE_OLDFILE)"
	$(if $(filter $(DRYRUN_RECURSIVE),true),$(MAKE_ARGS) $(MAKE) $(MAKE_DIR) $(patsubst %,-o %,$(MAKE_OLDFILE)) $(cmd) MAKE_OLDFILE="$(MAKE_OLDFILE)" DRYRUN=$(DRYRUN) RECURSIVE=$(RECURSIVE))
endef

ifeq ($(APP),)
INCLUDE_SUBDIRS                 := monorepo
else ifeq ($(APP), infra)
INCLUDE_SUBDIRS                 := subrepo infra
else
INCLUDE_SUBDIRS                 := subrepo app
endif

include $(wildcard $(INCLUDE_DIR)/def.*.mk)
include $(foreach subdir,$(INCLUDE_SUBDIRS),$(wildcard $(INCLUDE_DIR)/$(subdir)/def.*.mk))

# Accept arguments for CMDS targets
ifneq ($(filter $(CMDS),$(firstword $(MAKECMDGOALS))),)
# set $ARGS with following arguments
ARGS                            := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
ARGS                            := $(subst :,\:,$(ARGS))
ARGS                            := $(subst &,\&,$(ARGS))
# ...and turn them into do-nothing targets
$(eval $(ARGS):;@:)
endif
