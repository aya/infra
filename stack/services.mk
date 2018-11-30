services-sysctl:
	$(call docker-run,--privileged alpine:latest,sysctl -w vm.max_map_count=$(SYSCTL_VM_MAX_MAP_COUNT) >/dev/null) # elasticsearch
	$(call docker-run,--privileged alpine:latest,sysctl -w vm.overcommit_memory=1 >/dev/null) # redis
	$(call docker-run,--privileged alpine:latest,/bin/sh -c 'echo never > /sys/kernel/mm/transparent_hugepage/enabled') # redis
