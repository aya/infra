comma                           ?= ,
dollar                          ?= $
APP                             ?= $(SUBREPO)
AWS_DEFAULT_REGION              ?= eu-west-1
AWS_DEFAULT_OUTPUT              ?= text
BRANCH                          ?= $(shell git rev-parse --abbrev-ref HEAD)
COMMIT                          ?= $(shell git rev-parse HEAD)
CONTEXT                         ?= $(shell awk 'BEGIN {FS="="}; $$1 !~ /^(\#|$$)/ {print $$1}' .env.dist 2>/dev/null) BRANCH TAG UID USER VERSION
DEBUG                           ?= false
DOCKER                          ?= false
DRONE                           ?= false
DRYRUN                          ?= false
DRYRUN_IGNORE                   ?= false
DRYRUN_RECURSIVE                ?= false
ENV                             ?= local
ENV_FILE                        ?= .env
ENV_RESET                       ?= false
ENV_SYSTEM                       = $(shell printenv |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } ($$1 in A)' .env.dist - 2>/dev/null |awk '{print} END {print "$(foreach var,$(ENV_SYSTEM_VARS),$(if $($(var)),$(var)=$($(var))))"}' |awk -F "=" '!seen[$$1]++')
ENV_SYSTEM_VARS                 ?= APP AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN AWS_DEFAULT_REGION AWS_DEFAULT_OUTPUT AWS_PROFILE BRANCH COMPOSE_IGNORE_ORPHANS COMPOSE_PROJECT_NAME COMPOSE_SERVICE_NAME DOCKER_IMAGE_CLI DOCKER_IMAGE_REPO DOCKER_IMAGE_REPO_BASE DOCKER_IMAGE_SSH DOCKER_IMAGE_TAG DOCKER_INFRA_SSH ENV HOSTNAME GID MONOREPO_DIR MOUNT_NFS_CONFIG SUBREPO_DIR TAG UID USER VERSION
GID                             ?= $(shell id -g)
HOSTNAME                        ?= $(shell hostname |sed 's/\..*//')
MAKE_ARGS                       ?= ENV=$(ENV)
MONOREPO                        ?= $(if $(wildcard .git),$(notdir $(CURDIR)),$(notdir $(realpath $(CURDIR)/..)))
MONOREPO_DIR                    ?= $(if $(wildcard .git),$(CURDIR),$(realpath $(CURDIR)/..))
RECURSIVE                       ?= true
SUBREPO                         ?= $(notdir $(CURDIR))
SUBREPO_DIR                     ?= $(CURDIR)
SUBREPO_COMMIT                  ?= $(shell git rev-parse subrepo/$(SUBREPO)/$(BRANCH) 2>/dev/null)
TAG                             ?= $(shell git tag -l --points-at HEAD)
UID                             ?= $(shell id -u)
USER                            ?= $(shell id -nu)
VERSION                         ?= $(shell git describe --tags 2>/dev/null || git rev-parse HEAD)

include def.*.mk

# Accept arguments for CMDS targets
ifneq ($(filter $(CMDS),$(firstword $(MAKECMDGOALS))),)
# set $ARGS with following arguments
ARGS                            := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
ARGS                            := $(subst :,\:,$(ARGS))
ARGS                            := $(subst &,\&,$(ARGS))
# ...and turn them into do-nothing targets
$(eval $(ARGS):;@:)
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
DRYRUN_ECHO                      = $(if $(filter $(DRYRUN_IGNORE),true),,printf "${COLOR_BROWN}$(APP)${COLOR_RESET}[${COLOR_GREEN}$(MAKELEVEL)${COLOR_RESET}] ${COLOR_BLUE}$@${COLOR_RESET}:${COLOR_RESET} "; echo)
ifeq ($(RECURSIVE), true)
DRYRUN_RECURSIVE                := true
endif
endif

define make
	$(eval MAKE_OLDFILE := $(MAKE_OLDFILE) $(filter-out $(MAKE_OLDFILE), $^))
	$(DRYRUN_ECHO) $(MAKE_ARGS) $(MAKE) $(patsubst %,-o %,$(MAKE_OLDFILE)) $(1) MAKE_OLDFILE="$(MAKE_OLDFILE)"
	$(if $(filter $(DRYRUN_RECURSIVE),true),$(MAKE_ARGS) $(MAKE) $(patsubst %,-o %,$(MAKE_OLDFILE)) $(1) MAKE_OLDFILE="$(MAKE_OLDFILE)" DRYRUN=$(DRYRUN) RECURSIVE=$(RECURSIVE))
endef
