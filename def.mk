APP                             ?= $(SUBREPO)
APP_DIR                         ?= $(CURDIR)
BRANCH                          ?= $(shell git rev-parse --abbrev-ref HEAD)
COMMIT                          ?= $(shell git rev-parse HEAD)
CONTEXT                         ?= $(shell awk 'BEGIN {FS="="}; $$1 !~ /^(\#|$$)/ {print $$1}' .env.dist 2>/dev/null) BRANCH COMMIT TAG UID USER
DEBUG                           ?= false
DOCKER                          ?= false
DRONE                           ?= false
ENV                             ?= local
ENV_FILE                        ?= .env
ENV_RESET                       ?= false
ENV_SYSTEM                       = $(shell printenv |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } ($$1 in A)' .env.dist - 2>/dev/null |awk '{print} END {print "APP=$(APP)\nBRANCH=$(BRANCH)\nCOMMIT=$(COMMIT)\nCOMPOSE_IGNORE_ORPHANS=$(COMPOSE_IGNORE_ORPHANS)\nCOMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME)\nCOMPOSE_SERVICE_NAME=$(COMPOSE_SERVICE_NAME)\nDOCKER_IMAGE_REPO=$(DOCKER_IMAGE_REPO)\nDOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG)\nENV=$(ENV)\nGID=$(GID)\nMONOREPO_DIR=$(MONOREPO_DIR)\nUID=$(UID)\nUSER=$(USER)\nTAG=$(TAG)"}' |awk -F "=" '!seen[$$1]++')
GID                             ?= $(shell id -g)
MONOREPO                        ?= $(if $(wildcard .git),$(notdir $(CURDIR)),$(notdir $(realpath $(CURDIR)/..)))
MONOREPO_DIR                    ?= $(if $(wildcard .git),$(CURDIR),$(realpath $(CURDIR)/..))
SUBREPO                         ?= $(notdir $(CURDIR))
TAG                             ?= $(shell git tag -l --points-at HEAD)
UID                             ?= $(shell id -u)
USER                            ?= $(shell id -nu)

include def.*.mk

# Accept arguments for CMDS targets
ifneq ($(filter $(CMDS),$(firstword $(MAKECMDGOALS))),)
# set $ARGS with following arguments
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(ARGS):;@:)
endif
