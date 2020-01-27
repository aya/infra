##
# INFRA : those rules are fired first and passed to recursive make calls through the MAKE_ODLFILE variable to prevent make to fire them in each recursive call

.PHONY: bootstrap-infra
bootstrap-infra:
	$(call make,base,infra)

.PHONY: docker-infra-base
docker-infra-base: bootstrap-infra
ifneq ($(wildcard infra),)
ifneq (,$(filter $(MAKECMDGOALS),build config ps rebuild recreate restart start up))
	$(call make,$(patsubst %,base-%,$(MAKECMDGOALS)) STACK_BASE=base,infra)
endif
endif

.PHONY: docker-infra-node
docker-infra-node: bootstrap-infra
ifneq ($(wildcard infra),)
ifneq (,$(filter $(MAKECMDGOALS),build config ps rebuild recreate restart start up))
	$(call make,$(patsubst %,node-%,$(MAKECMDGOALS)) STACK_NODE=node,infra)
endif
endif

.PHONY: docker-infra-services
docker-infra-services: bootstrap-infra
ifneq ($(wildcard infra),)
ifneq (,$(filter $(MAKECMDGOALS),install reinstall build config ps rebuild recreate restart start up))
	$(call make,$(MAKECMDGOALS) STACK=services,infra)
endif
endif
