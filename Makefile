SCRIPTS="./Scripts"

BUILD_SETTINGS="gf-build-settings.sh"

.PHONY: help
help: ## display help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

get-build: ## get current build number
	 @$(SCRIPTS)/$(BUILD_SETTINGS) get "Build"

set-build: ## usage: b=3 make set-build
	 @$(SCRIPTS)/$(BUILD_SETTINGS) set "Build" $(b)

get-version: ## get current version number
	 @$(SCRIPTS)/$(BUILD_SETTINGS) get "Version"

set-version: ## usage: v=1.1 make set-version
	 @$(SCRIPTS)/$(BUILD_SETTINGS) set "Version" $(v)

clear-dd: ## clear derived data
	@$(SCRIPTS)/clear-derived-data.sh

clear-spm: ## clear spm cache
	@$(SCRIPTS)/clear-spm-cache.sh

rename-proj: ## rename project
	@$(SCRIPTS)/rename-xcodeproj.sh

minions-local: ## make minions local
	@$(SCRIPTS)/gf-minions.sh r2l

minions-remote: ## make minions remote
	@$(SCRIPTS)/gf-minions.sh l2r

minions-update: ## update local minions
	@make minions-remote
	@make minions-local

gf-update: ## update from original repo
	@$(SCRIPTS)/gf-update.sh
