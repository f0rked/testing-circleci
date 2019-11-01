.PHONY: clean lint test build

BIN_DIR				:= $(GOPATH)/bin
GOLANGCILINT	:= $(BIN_DIR)/golangci-lint
PROJECT_FILES := $(shell find . -name *.go)
OUTPUT_DIR		:= output
COVER_DIR 		:= $(OUTPUT_DIR)/coverage
COVER_FILE 		:= $(COVER_DIR)/coverage.out
RELEASE_DIR 	:= $(OUTPUT_DIR)/release
BINARY				:= hello

#PLATFORMS			:= linux darwin windows
#os 						= $(word 1, $@)
#build: $(PLATFORMS)
#$(PLATFORMS): test
#	mkdir -p $(RELEASE_DIR)
#	GOOS=$(os) GOARCH=amd64 go build -o $(RELEASE_DIR)/$(BINARY)-$(os)-amd64 cmd/hello.go

build: $(RELEASE_DIR)/$(BINARY)

$(RELEASE_DIR)/$(BINARY): test
	mkdir -p $(RELEASE_DIR)
	GOOS=linux GOARCH=amd64 go build -o $(RELEASE_DIR)/$(BINARY) cmd/hello.go

test: lint $(COVER_FILE)

$(COVER_FILE): $(PROJECT_FILES)
	mkdir -p $(COVER_DIR)
	go test -coverprofile=$(COVER_FILE) ./...

lint: $(GOLANGCILINT)
	$(BIN_DIR)/golangci-lint run -v ./...

clean:
	rm -rf output

$(GOLANGCILINT):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b $(BIN_DIR) v1.21.0
