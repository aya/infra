BRANCH                          ?= $(shell git rev-parse --abbrev-ref HEAD)
COMMIT                          ?= $(shell git rev-parse HEAD)
DEBUG                           ?= false
DRONE                           ?= false
ENV                             ?= local
ENV_FILE                        ?= .env
TAG                             ?= $(shell git tag -l --points-at HEAD)

include def.*.mk

# Accept arguments for CMDS targets
ifneq ($(filter $(CMDS),$(firstword $(MAKECMDGOALS))),)
# set $ARGS with following arguments
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# ...and turn them into do-nothing targets
$(eval $(ARGS):;@:)
endif
