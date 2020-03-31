##
# BOOTSTRAP

.PHONY: bootstrap-infra
bootstrap-infra: bootstrap

.PHONY: bootstrap-docker
bootstrap-docker: docker-network-create setup-sysctl
ifeq ($(SETUP_NFSD),true)
ifeq ($(HOST_SYSTEM),DARWIN)
	$(call setup-nfsd-osx)
endif
endif
