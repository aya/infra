define force
	while true; do [ $$(ps x |awk 'BEGIN {nargs=split("'"$$*"'",args)} $$field == args[1] { matched=1; for (i=1;i<=NF-field;i++) { if ($$(i+field) == args[i+1]) {matched++} } if (matched == nargs) {found++} } END {print found+0}' field=4) -eq 0 ] && $(ECHO) $(1) || sleep 1; done
endef

define ssh-connect
	$(eval hosts := $(1))
	$(eval command := $(2))
	$(eval user := $(or $(3),root))
	$(eval DOCKER_EXEC_OPTIONS := -it)
	$(foreach host,$(hosts),$(call exec,ssh -t $(user)@$(host) "$(command)") ||) true
endef

define ssh-exec
	$(eval hosts := $(1))
	$(eval command := $(2))
	$(eval user := $(or $(3),root))
	$(foreach host,$(hosts),$(call exec,ssh $(user)@$(host) "$(command)") &&) true
endef
