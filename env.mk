BRANCH         := $(shell git branch --no-color 2>/dev/null |awk '$$1 == "*" {match($$0, "("FS")+"); print substr($$0, RSTART+RLENGTH);}')
CONTEXT        += BRANCH $(shell awk 'BEGIN {FS="="}; {print $$1}' .env.dist 2>/dev/null)

.env: .env.dist
	$(call generate_env, .env)

-include .env

# update .env file with vars from .env.dist except those already set in system env
define generate_env
	@if [ -e $(1) ]; then \
		grep -v "`env | awk 'BEGIN {FS="="}; {print "^"$$1"="}'`" $(1).dist | grep -v "`cat $(1) | awk 'BEGIN {FS="="}; {print "^"$$1"="}'`" >> $(1); \
	else \
		touch $(1); \
		grep -v "`env | awk 'BEGIN {FS="="}; {print "^"$$1"="}'`" $(1).dist >> $(1); \
	fi;
endef
