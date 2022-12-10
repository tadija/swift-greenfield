SCRIPTS="./Scripts"

.PHONY: help
help: ## display help
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build-number: ## get current build number
	 @$(SCRIPTS)/env-common.sh get "Build"

bump-build: ## usage: b=3 make bump-build
	 @$(SCRIPTS)/env-common.sh set "Build" $(b)

version-number: ## get current version number
	 @$(SCRIPTS)/env-common.sh get "Version"

bump-version: ## usage: v=1.1 make bump-version
	 @$(SCRIPTS)/env-common.sh set "Version" $(v)

clear-dd: ## clear derived data
	@$(SCRIPTS)/clear-derived-data.sh

rename: ## rename project
	@$(SCRIPTS)/rename-xcodeproj.sh
