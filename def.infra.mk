CMDS                            += base-exec node-exec openstack terraform
COMPOSE_IGNORE_ORPHANS          ?= true
CONTEXT                         += COMPOSE_PROJECT_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_NAME
CRONLOCK_PREFIX                 ?= $(if $(filter $(ENV),prod preprod),1001pharmacies,$(USER)).$(ENV).$(APP).
CRONLOCK_VERBOSE                ?= yes
DOCKER_SERVICE                  ?= mysql
ELASTICSEARCH_PORT              ?= 9200
ENV_VARS                        += COMPOSE_IGNORE_ORPHANS ELASTICSEARCH_HOST ELASTICSEARCH_PORT GIT_AUTHOR_EMAIL GIT_AUTHOR_NAME SSL_HOSTNAME
GIT_AUTHOR_EMAIL                ?= $(shell git config user.email 2>/dev/null)
GIT_AUTHOR_NAME                 ?= $(shell git config user.name 2>/dev/null)
HOME                            ?= /home/$(USER)
MOUNT_NFS_CONFIG                ?= addr=$(MOUNT_NFS_HOST),actimeo=3,intr,noacl,noatime,nocto,nodiratime,nolock,soft,rsize=32768,wsize=32768,tcp,rw,vers=3
MOUNT_NFS_OPTIONS               ?= rw,rsize=8192,wsize=8192,bg,hard,intr,nfsvers=3,noatime,nodiratime,actimeo=3
MOUNT_NFS_PATH                  ?= /mnt/nfs
REMOTE                          ?= ssh://git@github.com/1001Pharmacies/$(SUBREPO)
SETUP_NFSD                      ?= false
SETUP_NFSD_OSX_CONFIG           ?= nfs.server.bonjour=0 nfs.server.mount.regular_files=1 nfs.server.mount.require_resv_port=0 nfs.server.nfsd_threads=16 nfs.server.async=1
SETUP_SYSCTL                    ?= true
SETUP_SYSCTL_CONFIG             ?= vm.max_map_count=262144 vm.overcommit_memory=1 fs.file-max=8388608 net.core.somaxconn=1024
SHELL                           ?= /bin/sh
STACK                           ?= logs $(if $(filter $(ENV),prod preprod),,services)
STACK_BASE                      ?= base
STACK_NODE                      ?= node

ifeq ($(ENV),prod)
CRONLOCK_HOST                   ?= ectoggle.cpumir.ng.0001.euw1.cache.amazonaws.com
ELASTICSEARCH_HOST              ?= internal-terraform-elb-es5-1081416480.eu-west-1.elb.amazonaws.com
MOUNT_NFS_HOST                  ?= 10.131.148.6
MOUNT_NFS_DISK                  ?= $(MOUNT_NFS_HOST):/space/NFS/www.1001pharmacies.com
else ifeq ($(ENV),preprod)
CRONLOCK_HOST                   ?= enovasanteecpptoggle.cpumir.0001.euw1.cache.amazonaws.com
ELASTICSEARCH_HOST              ?= internal-terraform-elb-es5pp-587305451.eu-west-1.elb.amazonaws.com
MOUNT_NFS_HOST                  ?= 10.131.144.6
MOUNT_NFS_DISK                  ?= $(MOUNT_NFS_HOST):/space/NFS/preprod.1001pharmacies.com
else
CRONLOCK_HOST                   ?= redis
ELASTICSEARCH_HOST              ?= elasticsearch
endif

define setup-nfsd-osx
	$(eval dir:=$(or $(1),$(MONOREPO_DIR)))
	$(eval uid:=$(or $(2),$(UID)))
	$(eval gid:=$(or $(3),$(GID)))
	grep "$(dir)" /etc/exports >/dev/null 2>&1 || echo "$(dir) -alldirs -mapall=$(uid):$(gid) localhost" |sudo tee -a /etc/exports >/dev/null
	$(foreach config,$(SETUP_NFSD_OSX_CONFIG),grep "$(config)" /etc/nfs.conf >/dev/null 2>&1 || echo "$(config)" |sudo tee -a /etc/nfs.conf >/dev/null &&) true
	nfsd status >/dev/null || sudo nfsd enable
	showmount -e localhost |grep "$(dir)" >/dev/null 2>&1 || sudo nfsd restart
endef
