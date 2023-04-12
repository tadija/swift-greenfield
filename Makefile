SCRIPTS="./Scripts"
CONFIG="config-env-bs.sh"

.PHONY: help
help: ## display help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

get-build: ## get current build number
	 @$(SCRIPTS)/$(CONFIG) get "Build"

set-build: ## usage: b=3 make set-build
	 @$(SCRIPTS)/$(CONFIG) set "Build" $(b)

get-version: ## get current version number
	 @$(SCRIPTS)/$(CONFIG) get "Version"

set-version: ## usage: v=1.1 make set-version
	 @$(SCRIPTS)/$(CONFIG) set "Version" $(v)

clear-dd: ## clear derived data
	@$(SCRIPTS)/clear-derived-data.sh

rename-proj: ## rename project
	@$(SCRIPTS)/rename-xcodeproj.sh
