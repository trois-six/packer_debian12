.PHONY: help all bake clean distclean

.DEFAULT_GOAL := all

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

all: bake
bake: ## Create packer img
	@rm -rf img && packer init && packer build debian12.pkr.hcl

clean: ## Remove img
	rm -f img

distclean: ## Remove all dynamic content
	rm -f img packer_cache
