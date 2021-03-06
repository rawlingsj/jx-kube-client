SHELL := /bin/bash
GO := GO111MODULE=on GO15VENDOREXPERIMENT=1 go
GO_NOMOD := GO111MODULE=off go
GOTEST := $(GO) test
PACKAGE_DIRS := $(shell $(GO) list ./... | grep -v /vendor/)
GO_DEPENDENCIES := $(shell find . -type f -name '*.go')

build:
	$(GO) build ./...

test: build
	$(GOTEST) --tags=unit -failfast -short ./...

get-fmt-deps: ## Install test dependencies
	$(GO_NOMOD) get golang.org/x/tools/cmd/goimports

fmt: importfmt ## Format the code
	@FORMATTED=`$(GO) fmt $(PACKAGE_DIRS)`
	@([[ ! -z "$(FORMATTED)" ]] && printf "Fixed unformatted files:\n$(FORMATTED)") || true

importfmt: get-fmt-deps
	@echo "Formatting the imports..."
	goimports -w $(GO_DEPENDENCIES)

.PHONY: lint
lint: ## Lint the code
	./hack/linter.sh

.PHONY: modtidy
modtidy:
	$(GO) mod tidy

check: fmt build test
