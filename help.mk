.PHONY: blank1 blank2 context help target usage

COLOR_RESET    := \033[0m
COLOR_GREEN    := \033[32m
COLOR_BROWN    := \033[33m
COLOR_BLUE     := \033[36m

##
# HELP

help: usage blank1 target blank2 context ## This help

usage:
	printf "${COLOR_BROWN}Usage:${COLOR_RESET}\n"
	printf "make [target]\n"

blank1 blank2:
	printf "\n"

## Show available targets
target:
	printf "${COLOR_BROWN}Targets:${COLOR_RESET}\n"
	awk 'BEGIN {FS = ":.*?## "}; $$0 ~ /^[a-zA-Z_-]+:.*?## .*$$/ {printf "${COLOR_BLUE}%-30s${COLOR_RESET} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## Show current context
context:
	printf "${COLOR_BROWN}Context:${COLOR_RESET}\n"
	$(MAKE) context-list

context-list: $(CONTEXT)

$(CONTEXT):
	$(MAKE) print-$@

print-%: ; @printf "${COLOR_BLUE}%-30s${COLOR_RESET} ${COLOR_GREEN}%s${COLOR_RESET}\n" $* "$($*)"
