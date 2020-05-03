APPS                            ?= $(sort $(filter-out $(DIRS), $(patsubst %/,%,$(wildcard */)) ))
APPS_NAME                       ?= $(foreach app,$(APPS),$(or $(shell awk -F '=' '$$1 == "APP" {print $$2}' $(or $(wildcard $(app)/.env),$(wildcard $(app)/.env.$(ENV)),$(app)/.env.dist) 2>/dev/null),$(app)))
CMDS                            += copy master-tag release release-check release-create release-finish subrepo-push update-subrepo
CONTEXT                         += APPS APPS_NAME ENV RELEASE_INSTALL
DIRS                            ?= $(INFRA) $(MAKE_DIR) $(PARAMETERS) $(SHARED)
RELEASE_UPGRADE                 ?= $(filter v%, $(shell git tag -l |awk '/$(RELEASE_INSTALL)/,0' |sed '$$d'))
RELEASE_VERSION                 ?= $(firstword $(subst -, ,$(VERSION)))
SUBREPOS                        ?= $(filter subrepo/%, $(shell git remote))

# CI/CD
ifneq (,$(filter true,$(DRONE)))
CONTEXT                         += DRONE_BRANCH DRONE_BUILD_EVENT DRONE_BUILD_NUMBER DRONE_COMMIT_AUTHOR DRONE_COMMIT_REF DRONE_COMMIT_SHA DRONE_TAG
# limit APPS to those impacted by the PR
ifneq (,$(filter $(DRONE_BUILD_EVENT),pull_request))
# filter-out to prevent make targets to get through DIRS folders
APPS                            := $(filter-out $(DIRS), $(shell git diff --name-only origin/$(DRONE_BRANCH) $(DRONE_COMMIT_SHA) 2>/dev/null |awk -F '/' 'NF>1 && !seen[$$1]++ {print $$1}'))
endif
# limit APPS to those impacted by the merge
ifneq (,$(filter $(DRONE_BUILD_EVENT),push))
# filter-out to prevent make targets to get through DIRS folders
APPS                            := $(filter-out $(DIRS), $(shell git diff --name-only origin/$(DRONE_BRANCH) $(DRONE_COMMIT_SHA)^^ 2>/dev/null |awk -F '/' 'NF>1 && !seen[$$1]++ {print $$1}'))
endif
# limit APPS to those impacted by the tag
ifneq (,$(filter $(DRONE_BUILD_EVENT),tag))
# for hotfix only
ifneq (0,$(lastword $(subst ., ,$(DRONE_TAG))))
# filter-out to prevent make targets to get through DIRS folders
APPS                            := $(filter-out $(DIRS), $(shell git diff --name-only origin/$(DRONE_BRANCH) $(shell git describe --abbrev=0 --tags $(DRONE_TAG)^) 2>/dev/null |awk -F '/' 'NF>1 && !seen[$$1]++ {print $$1}'))
endif
endif
endif
