.PHONY: clean acceptance release lint test build

BIN_DIR				:= $(GOPATH)/bin
GOLANGCI_LINT	:= $(BIN_DIR)/golangci-lint
GOLANG_GODOG	:= $(BIN_DIR)/godog
PROJECT_FILES	:= $(shell find . -name *.go)
OUTPUT_DIR		:= output
COVER_DIR			:= $(OUTPUT_DIR)/coverage
COVER_FILE		:= $(COVER_DIR)/coverage.out
RELEASE_DIR		:= $(OUTPUT_DIR)/release
BINARY				:= hello
PLATFORMS			:= linux darwin windows
os						= $(word 1, $@)

build: $(OUTPUT_DIR)/$(BINARY)

$(OUTPUT_DIR)/$(BINARY): $(COVER_FILE) $(PROJECT_FILES)
	mkdir -p $(OUTPUT_DIR)
	GOOS=linux GOARCH=amd64 go build -o $(OUTPUT_DIR)/$(BINARY) cmd/hello.go

test: lint $(COVER_FILE)

$(COVER_FILE): $(PROJECT_FILES)
	mkdir -p $(COVER_DIR)
	go test -v -coverprofile=$(COVER_FILE) ./...

lint: $(GOLANGCI_LINT)
	$(GOLANGCI_LINT) run -v ./...

acceptance: $(GOLANG_GODOG) $(OUTPUT_DIR)/$(BINARY)
	cd features && HELLO_BINARY=../$(OUTPUT_DIR)/$(BINARY) $(GOLANG_GODOG) . && cd ..

release: $(PLATFORMS)

$(PLATFORMS):
	mkdir -p $(RELEASE_DIR)
	GOOS=$(os) GOARCH=amd64 go build -o $(RELEASE_DIR)/$(BINARY)-$(os)-amd64 cmd/hello.go

clean:
	rm -rf output

$(GOLANGCI_LINT):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b $(BIN_DIR) v1.21.0

$(GOLANG_GODOG):
	go get -u github.com/DATA-DOG/godog/cmd/godog
