BRANCH                          ?= $(shell git rev-parse --abbrev-ref HEAD)
COMMIT                          ?= $(shell git rev-parse HEAD)
CONTEXT                         ?= $(shell awk 'BEGIN {FS="="}; {print $$1}' .env.dist 2>/dev/null) BRANCH COMMIT TAG
DEBUG                           ?= false
DRONE                           ?= false
ENV                             ?= local
ENV_FILE                        ?= .env
ENV_SYSTEM                      ?= $(shell printenv |awk -F '=' 'NR == FNR { A[$$1]; next } ($$1 in A)' .env.dist - 2>/dev/null |awk '{print} END {print "APP=$(APP)\nBRANCH=$(BRANCH)\nCOMMIT=$(COMMIT)\nCOMPOSE_IGNORE_ORPHANS=$(COMPOSE_IGNORE_ORPHANS)\nCOMPOSE_PROJECT_NAME=$(COMPOSE_PROJECT_NAME)\nENV=$(ENV)\nTAG=$(TAG)"}' |awk -F "=" '!seen[$$1]++')
TAG                             ?= $(shell git tag -l --points-at HEAD)

include def.*.mk

# Accept arguments for CMDS targets
ifneq ($(filter $(CMDS),$(firstword $(MAKECMDGOALS))),)
# set $ARGS with following arguments
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(ARGS):;@:)
endif
