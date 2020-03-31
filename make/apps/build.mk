##
# BUILD

.PHONY: build-rm
build-rm:
	$(call exec,rm -rf build && mkdir -p build)
