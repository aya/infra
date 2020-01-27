##
# STACK

.PHONY: stack
stack: $(patsubst %,stack-%,$(STACK)) bootstrap-infra
	$(call .env)

.PHONY: stack-%
stack-%: ## Start docker stack
	$(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*.yml)
	$(if $(wildcard stack/$*.$(ENV).yml), $(eval COMPOSE_FILE:=$(COMPOSE_FILE) stack/$*.$(ENV).yml))
	$(if $(wildcard stack/.env.$*.dist), $(call .env,,stack/.env.$*))

include $(wildcard stack/*.mk)
