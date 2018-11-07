docker-sysctl:
	$(call docker-run,--privileged alpine:latest,sysctl -w vm.max_map_count=$(SYSCTL_VM_MAX_MAP_COUNT) >/dev/null) # elasticsearch
	$(call docker-run,--privileged alpine:latest,sysctl -w vm.overcommit_memory=1 >/dev/null) # redis
	$(call docker-run,--privileged alpine:latest,/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled') # redis

ssh-add:
	$(eval comma := ,)
	$(call docker-run,--mount source=$(ENV)_$(APP)_ssh-agent$(comma)target=/tmp/ssh-agent 1001pharmadev/ssh-agent:latest,ssh-add -l >/dev/null) || \
	$(call docker-run,--mount source=$(ENV)_$(APP)_ssh-agent$(comma)target=/tmp/ssh-agent -v $(SSH_DIR):/root/.ssh 1001pharmadev/ssh-agent:latest,ssh-add /root/.ssh/*_rsa)

