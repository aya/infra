.env: .env.dist
	$(call .env)

-include .env

ifneq (,$(filter true,$(ENV_RESET)))
env_reset := -i
endif

SHELL:=/bin/bash
define .env ## update $(env_file) file with vars from $(env_dist) except those already set in system env
	$(eval env_path:=$(or $(1),.))
	$(eval env_file:=$(env_path)/.env)
	$(if $(wildcard $(env_file).$(ENV)), $(eval env_dist:=$(env_path)/.env.$(ENV)), $(eval env_dist:=$(env_path)/.env.dist))
	# if .env.dist exists then
	#   touch .env
	#   print ENV vars | print vars from .env.dist not set in STDIN                 | print vars from STDIN not set in .env                                      | print ENV vars  (ENV vars existing in .env.dist                                                               + .env.dist vars   - empty lines or comments - duplicate lines)        to replace vars in STDIN with their value from the new ENV                                                            >> .env
	if [ -f "$(env_dist)" ]; then \
		touch $(env_file); \
		printenv |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } !($$1 in A)' - $(env_dist) |awk -F '=' 'ARGV[1] == FILENAME { A[$$1]; next } !($$1 in A)' $(env_file) - |(IFS=$$'\n'; env $(env_reset) $$(env |awk -F '=' 'NR == FNR { if($$1 !~ /^(\#|$$)/) { A[$$1]; next } } ($$1 in A)' $(env_dist) - |cat - $(env_dist) |sed -e /^$$/d -e /^#/d |awk -F "=" '!seen[$$1]++') awk '{while(match($$0,"[$$]{[^}]*}")) {var=substr($$0,RSTART+2,RLENGTH -3);gsub("[$$]{"var"}",ENVIRON[var])} print}') >> $(env_file); \
	fi
endef
