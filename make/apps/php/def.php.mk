BUILD_APP_VARS                  += SYMFONY_ENV
DOCKER_SERVICE                  ?= php

ifneq (,$(filter $(ENV),prod preprod))
SYMFONY_ENV                     ?= prod
else
SYMFONY_ENV                     ?= dev
endif
