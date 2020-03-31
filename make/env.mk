.env: .env.dist
	$(call .env)

-include .env

ifneq (,$(filter true,$(ENV_RESET)))
env_reset := -i
endif

SHELL:=/bin/bash
##
# function .env
## update .env file with vars from .env.dist not set in environment
## this function adds variables from the .env.dist to the .env file
## when it does not exist in the environment and does substitution,
## to replace variables with their value when adding it to the .env
	# 1st arg: directory holding the .env file, default to .
	# eval path to .env file, default to ./.env
	# 2nd arg: base path to .env.dist file, default to ./.env
	# eval path to .env.dist file, default to ./.env.dist or ./.env.$(ENV) if it exists
	# if .env.dist exists then
		# create the .env file
		# read environment variables
		  # keep variables from .env.dist that does not exist in environment variables
		  # add variables from make command line
		  # keep variables that exists in .env.dist
		  # keep variables that does not exist in .env
		  # read variables in a subshell with multiline support
	        # create a new environment (empty if $(ENV_RESET) is true)
			  # read environment variables and keep only those existing in .env.dist
			  # add .env.dist variables
			  # remove empty lines or comments (from .env.dist)
			  # remove duplicate lines
		    # replace vars in stdin with their value from the new environment
		  # remove residual empty lines or comments
		  # add it to the .env file
define .env
	$(eval env_path:=$(or $(1),.))
	$(eval env_file:=$(env_path)/.env)
	$(eval env_dist:=$(or $(2),$(env_file)))
	$(if $(wildcard $(env_dist).$(ENV)), $(eval env_dist:=$(env_dist).$(ENV)), $(eval env_dist:=$(env_dist).dist))
	if [ -f "$(env_dist)" ]; then \
		touch $(env_file); \
		printenv \
		  |awk -F '=' 'NR == FNR { if($$1 !~ /^(#|$$)/) { A[$$1]; next } } !($$1 in A)' - $(env_dist) \
		  |awk '{print} END {split("$(MAKECMDVARS)",vars," "); for (var in vars) {print vars[var]"="ENVIRON[vars[var]]};}' \
		  |awk -F '=' 'ARGV[1] == FILENAME { A[$$1]; next } ($$1 in A)' $(env_dist) - 2>/dev/null \
		  |awk -F '=' 'ARGV[1] == FILENAME { A[$$1]; next } !($$1 in A)' $(env_file) - 2>/dev/null \
		  |(IFS=$$'\n'; \
		    env $(env_reset) \
			  $$(env |awk -F '=' 'NR == FNR { if($$1 !~ /^(#|$$)/) { A[$$1]; next } } ($$1 in A)' $(env_dist) - \
		        |cat - $(env_dist) \
		        |sed -e /^$$/d -e /^#/d \
		        |awk -F '=' '!seen[$$1]++') \
			  awk '{while(match($$0,"[$$]{[^}]*}")) {var=substr($$0,RSTART+2,RLENGTH-3);gsub("[$$]{"var"}",ENVIRON[var])} print}') \
		  |sed -e /^$$/d -e /^#/d \
		  >> $(env_file); \
	fi
endef
