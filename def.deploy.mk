DEPLOY_PING_TEXT                ?= app: *$(APP)* branch: *$(BRANCH)* env: *$(ENV)* version: *$(VERSION)* container: *$(CONTAINER)* host: *$(HOST)*
DEPLOY_SLACK_HOOK               ?= https://hooks.slack.com/services/123456789/123456789/ABCDEFGHIJKLMNOPQRSTUVWX
HASH                            ?= $(shell date +%s)
SERVER_NAME                     ?= $(DOCKER_REGISTRY_USERNAME).$(ENV).$(APP)
