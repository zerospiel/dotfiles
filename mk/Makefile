BUILD_ENVPARMS:=CGO_ENABLED=0
CI_PROJECT_DIR?=$(shell pwd)
INTERNAL_PKG_DIR=$(CURDIR)/internal/pkg
PROTO_FILES_PATH=$(CURDIR)/api

# Database and migrations
MIGRATION_FOLDER=$(INTERNAL_PKG_DIR)/database/migrations
ifeq ($(POSTGRES_SETUP_TEST),)
	POSTGRES_SETUP_TEST := user=test password=test dbname=TEST host=127.0.0.1 port=6432 sslmode=disable
endif

.PHONY: psql-test
psql-test:
	docker-compose -p SERVICE_NAME -f ./build/dev/docker-compose.yml exec test-postgres psql -U test TEST

.PHONY: migration-create
migration-create:
	goose -dir "$(MIGRATION_FOLDER)" create "$(name)" sql

.PHONY: test-migrations-up
test-migrations-up:
	$(BUILD_ENVPARMS) goose -dir "$(MIGRATION_FOLDER)" postgres "$(POSTGRES_SETUP_TEST)" up

.PHONY: test-migrations-down
test-migrations-down:
	$(BUILD_ENVPARMS) goose -dir "$(MIGRATION_FOLDER)" postgres "$(POSTGRES_SETUP_TEST)" down
# Database and migrations

# Docker and compose
.PHONY: compose-up
compose-up:
	docker-compose -p SERVICE_NAME -f ./build/dev/docker-compose.yml up -d

.PHONY: compose-rs
compose-rs:
	make compose-rm
	make compose-up

.PHONY: compose-rm
compose-rm:
	docker-compose -p SERVICE_NAME -f ./build/dev/docker-compose.yml rm -fvs
# Docker and compose

# Build and run
# for local development only
# NOTE: sed -i '' — is fixing bug due to macOS' inability to behave like a correct full UNIX/GNU kernel
.PHONY: run-test-server
run-test-server:
	make build
	make test-migrations-up
	$(shell grep -n START_CONSUMER $(CURDIR)/.o3/k8s/values_local.yaml | cut -d ":" -f 1 | awk '{print $$1+1}' | xargs -I {} sh -c "sed -i '' '{}s/true/false/' $(CURDIR)/.o3/k8s/values_local.yaml")
	./bin/SERVICE_NAME --local-config-enabled --local-config-name=values_local.yaml

# for local development only with consumer connected to STG cluster
.PHONY: consumer-run-test-server
consumer-run-test-server:
	make build
	make test-migrations-up
	$(shell grep -n START_CONSUMER $(CURDIR)/.o3/k8s/values_local.yaml | cut -d ":" -f 1 | awk '{print $$1+1}' | xargs -I {} sh -c "sed -i '' '{}s/false/true/' $(CURDIR)/.o3/k8s/values_local.yaml")
	./bin/SERVICE_NAME --local-config-enabled --local-config-name=values_local.yaml
# Build and run

# Tests
.PHONY: test
test:
	$(BUILD_ENVPARMS) go test ./internal/... -count=1 -run=$(run)

.PHONY: test-race
test-race:
	go test ./internal/... -count=1 -run=$(run) -race

.PHONY: test-db
test-db:
	$(BUILD_ENVPARMS) go test ./test/db -count=1 -run=$(run)

.PHONY: test-repos
test-repos:
	$(BUILD_ENVPARMS) go test ./test/repos -timeout=60s -count=1 -run=$(run)

.PHONY: test-internal-integration
test-internal-integration:
	$(BUILD_ENVPARMS) go test ./test/internal -count=1 -run=$(run)

.PHONY: test-internal-integration-all
test-internal-integration-all:
	sh ./build/scripts/tests.sh

.PHONY: test-with-cover
test-with-cover:
	$(BUILD_ENVPARMS) go test -cover ./internal/... -coverprofile=coverage.out

.PHONY: test-internal-integration-with-cover
test-internal-integration-with-cover:
	$(BUILD_ENVPARMS) go test -coverpkg="./internal/..." -a -c -tags=testrunmain -ldflags "$(LDFLAGS)" -o $(CI_PROJECT_DIR)/bin/SERVICE_NAME-test ./cmd/SERVICE_NAME/
	SERVICE_NAME_API_USE_LOCAL_CONSUMER=false \
	./bin/SERVICE_NAME-test -test.run=TestRunMain -test.coverprofile=internal_integration.out >> temp.log & echo $$! > test.PID
	make test-internal-integration-all
	echo $$(cat test.PID); kill -2 $$(cat test.PID); rm test.PID
	sleep 10
# Tests

# Cover
# for local coverage
.PHONY: run-cover-server
run-cover-server:
	$(BUILD_ENVPARMS) go test -coverpkg="./internal/..." -a -c -tags=testrunmain -ldflags "$(LDFLAGS)" -o $(CI_PROJECT_DIR)/bin/SERVICE_NAME-test ./cmd/SERVICE_NAME/
	./bin/SERVICE_NAME-test -test.run=TestRunMain -test.coverprofile=internal_integration.out >> temp.log &

.PHONY: cover-integration
cover-integration:
	CI_PROJECT_DIR=. make run-cover-server
	make test-internal-integration; make kill-coverage-server

.PHONY: kill-coverage-server
kill-coverage-server:
	pkill SERVICE_NAME-test

.PHONY: merge-and-show-cover
merge-and-show-cover:
	$(GOPATH)/bin/gocovmerge *.out | grep -vE ".+_mock\.go:.+$$" > all.out
	$(BUILD_ENVPARMS) go tool cover -html=all.out -o all.html
	$(BUILD_ENVPARMS) go tool cover -func=all.out
# Cover

# Misc
.PHONY: generate
generate:
	protoc -I $(PROTO_FILES_PATH):./vendor.pb --validate_out="lang=gogo:$(PATH_TO_PKG_IMPLEMENTATION)" $(PROTO_FILES_PATH)/statistics.proto

.PHONY: generate-mock
generate-mock:
	$(BUILD_ENVPARMS) minimock -i "$(INTERNAL_PKG_DIR)/domain.*" -o "$(INTERNAL_PKG_DIR)/domain/mock/" -s "_mock.go"

.PHONY: goimports
goimports:
	$(info #Running goimports...)
	find . -name "*.go" | grep -vE "^(\.\/pkg\/)|vendor|_mock.go" | xargs -n1 goimports -w
# Misc