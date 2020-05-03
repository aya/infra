##
# UPDATE

## Update /etc/hosts
.PHONY: update-hosts
update-hosts:
ifneq (,$(filter $(ENV),local))
	cat */.env 2>/dev/null |grep -Eo 'urlprefix-[^/]+' |sed 's/urlprefix-//' |while read host; do grep $$host /etc/hosts >/dev/null 2>&1 || { echo "Adding $$host to /etc/hosts"; echo 127.0.0.1 $$host |$(ECHO) sudo tee -a /etc/hosts >/dev/null; }; done
endif

.PHONY: update-$(PARAMETERS)
update-$(PARAMETERS): $(PARAMETERS)

$(PARAMETERS): bootstrap-infra
	$(call exec,[ -d $(PARAMETERS) ] && cd $(PARAMETERS) && git pull --quiet || git clone --quiet $(GIT_PARAMETERS_REPOSITORY))

## Update release version number in .env
.PHONY: update-release
update-release:
	$(ECHO) awk -v s=RELEASE_INSTALL=$(RELEASE_VERSION) '/^RELEASE_INSTALL=/{$$0=s;f=1} {a[++n]=$$0} END{if(!f)a[++n]=s;for(i=1;i<=n;i++)print a[i]>ARGV[1]}' .env

## Update remotes
.PHONY: update-remotes
update-remotes: bootstrap-infra
	$(call exec,git fetch --all --prune --tags -u)

.PHONY: update-remote-%
update-remote-%: bootstrap-infra
	$(call exec,git fetch --prune --tags -u $*)

## Update subrepos
.PHONY: update-subrepos
update-subrepos: bootstrap-infra git-stash $(APPS) update-subrepo-infra git-unstash ## Update subrepos
	$(call exec,git push upstream $(BRANCH))

.PHONY: update-subrepo-%
update-subrepo-%: bootstrap-infra
	$(if $(wildcard $*/Makefile),$(call make,update-subrepo,$*))

.PHONY: update-upstream
update-upstream: .git/refs/remotes/upstream/master
	$(call exec,git fetch upstream "+refs/tags/*:refs/tags/*")

.git/refs/remotes/upstream/master: bootstrap-infra
	$(call exec,git remote add upstream $(GIT_UPSTREAM_REPOSITORY) 2>/dev/null ||:)