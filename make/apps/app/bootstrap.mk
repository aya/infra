##
# BOOTSTRAP

.PHONY: boostrap-docker
bootstrap-docker: docker-network-create docker-infra-images docker-compose-up

.PHONY: bootstrap-infra
bootstrap-infra:
ifneq ($(wildcard ../infra),)
	$(call make,bootstrap,../infra)
endif
