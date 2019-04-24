CMDS                            += base-exec node-exec openstack terraform
COMPOSE_IGNORE_ORPHANS          ?= true
CONTEXT                         += COMPOSE_PROJECT_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_NAME
DOCKER_SERVICE                  ?= mysql
ENV_SYSTEM_VARS                 += COMPOSE_IGNORE_ORPHANS
GIT_AUTHOR_EMAIL                ?= $(shell git config user.email 2>/dev/null)
GIT_AUTHOR_NAME                 ?= $(shell git config user.name 2>/dev/null)
HOME                            ?= /home/$(USER)
REMOTE                          ?= ssh://git@github.com/1001Pharmacies/$(SUBREPO)
SETUP_NFSD                      ?= false
SETUP_NFSD_OSX_CONFIG           ?= nfs.server.bonjour=0 nfs.server.mount.regular_files=1 nfs.server.mount.require_resv_port=0 nfs.server.nfsd_threads=16 nfs.server.async=1
SETUP_SYSCTL                    ?= true
SETUP_SYSCTL_CONFIG             ?= vm.max_map_count=262144 vm.overcommit_memory=1 fs.file-max=8388608 net.core.somaxconn=1024
SHELL                           ?= /bin/sh
STACK                           ?= services
STACK_BASE                      ?= base
STACK_NODE                      ?= node

define setup-nfsd-osx
	$(eval dir:=$(or $(1),$(MONOREPO_DIR)))
	$(eval uid:=$(or $(2),$(UID)))
	$(eval gid:=$(or $(3),$(GID)))
	grep "$(dir)" /etc/exports >/dev/null 2>&1 || echo "$(dir) -alldirs -mapall=$(uid):$(gid) localhost" |sudo tee -a /etc/exports >/dev/null
	$(foreach config,$(SETUP_NFSD_OSX_CONFIG),grep "$(config)" /etc/nfs.conf >/dev/null 2>&1 || echo "$(config)" |sudo tee -a /etc/nfs.conf >/dev/null &&) true
	nfsd status >/dev/null || sudo nfsd enable
	showmount -e localhost |grep "$(dir)" >/dev/null 2>&1 || sudo nfsd restart
endef
