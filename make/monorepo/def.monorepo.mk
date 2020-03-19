APPS                            ?= $(sort $(filter-out $(DIRS), $(patsubst %/,%,$(wildcard */)) ))
CMDS                            += master-tag release release-check release-create release-finish subrepo-push update-subrepo
CONTEXT                         += APPS ENV RELEASE_INSTALL
DIRS                            ?= infra make parameters shared
RELEASE_UPGRADE                 ?= $(filter v3.%, $(shell git tag -l |awk '/$(RELEASE_INSTALL)/,0' |sed '$$d'))
RELEASE_VERSION                 ?= $(firstword $(subst -, ,$(VERSION)))
REMOTE                          ?= ssh://git@github.com/1001Pharmacies/1001Pharmacies
SUBREPOS                        ?= $(filter subrepo/%, $(shell git remote))

# CI/CD
ifneq (,$(filter true,$(DRONE)))
CONTEXT                         += DRONE_BRANCH DRONE_BUILD_EVENT DRONE_BUILD_NUMBER DRONE_COMMIT_AUTHOR DRONE_COMMIT_REF DRONE_COMMIT_SHA DRONE_TAG
# APPS impacted by PR only
ifneq (,$(filter $(DRONE_BUILD_EVENT),pull_request))
# filter-out to prevent make targets to get through DIRS folders
APPS                            := $(filter-out $(DIRS), $(shell git diff --name-only origin/$(DRONE_BRANCH) $(DRONE_COMMIT_SHA) 2>/dev/null |awk -F '/' 'NF>1 && !seen[$$1]++ {print $$1}'))
endif
# APPS impacted by merge only
ifneq (,$(filter $(DRONE_BUILD_EVENT),push))
# filter-out to prevent make targets to get through DIRS folders
APPS                            := $(filter-out $(DIRS), $(shell git diff --name-only origin/$(DRONE_BRANCH) $(DRONE_COMMIT_SHA)^^ 2>/dev/null |awk -F '/' 'NF>1 && !seen[$$1]++ {print $$1}'))
endif
endif
