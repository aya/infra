APPS                            ?= $(sort $(filter-out $(DIRS), $(patsubst %/,%,$(wildcard */)) ))
APPS_NAME                       ?= $(foreach app,$(APPS),$(or $(shell awk -F '=' '$$1 == "APP" {print $$2}' $(or $(wildcard $(app)/.env),$(wildcard $(app)/.env.$(ENV)),$(app)/.env.dist) 2>/dev/null),$(app)))
CMDS                            += copy master-tag release release-check release-create release-finish subrepo-push update-subrepo
CONTEXT                         += APPS APPS_NAME ENV RELEASE_INSTALL
DIRS                            ?= $(if $(filter true,$(DRONE)),$(if $(filter down,$(MAKECMDGOALS)),$(INFRA))) $(MAKE_DIR) $(PARAMETERS) $(SHARED)
RELEASE_UPGRADE                 ?= $(filter v%, $(shell git tag -l |awk '/$(RELEASE_INSTALL)/,0' |sed '$$d'))
RELEASE_VERSION                 ?= $(firstword $(subst -, ,$(VERSION)))
SUBREPOS                        ?= $(filter subrepo/%, $(shell git remote))

# CI/CD
ifneq (,$(filter true,$(DRONE)))
ifneq (,$(filter $(DRONE_BUILD_EVENT),pull_request push))
COMMIT_AFTER                    := $(DRONE_COMMIT_AFTER)
COMMIT_BEFORE                   := $(DRONE_COMMIT_BEFORE)
endif
ifneq (,$(filter $(DRONE_BUILD_EVENT),tag))
COMMIT_AFTER                    := $(DRONE_TAG)
COMMIT_BEFORE                   := $(shell git describe --abbrev=0 --tags $(DRONE_TAG)^)
endif
# limit to APPS impacted by the commit
APPS                            := $(sort $(filter-out $(DIRS), $(shell git diff --name-only $(COMMIT_BEFORE) $(COMMIT_AFTER) 2>/dev/null |awk -F '/' 'NF>1 && !seen[$$1]++ {print $$1}')))
CONTEXT                         += DRONE_BRANCH DRONE_BUILD_EVENT DRONE_BUILD_NUMBER DRONE_COMMIT DRONE_COMMIT_AFTER DRONE_COMMIT_AUTHOR DRONE_COMMIT_BEFORE DRONE_COMMIT_REF DRONE_COMMIT_SHA
endif
