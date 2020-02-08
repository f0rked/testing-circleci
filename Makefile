#
BIN_DIR					:= $(GOPATH)/bin
GOLANGCI_LINT		:= $(BIN_DIR)/golangci-lint
GOLANG_GODOG		:= $(BIN_DIR)/godog
GOLANG_GHR			:= $(BIN_DIR)/ghr

DOCKER_DIR			:= docker
OUTPUT_DIR			:= output
COVER_DIR				:= $(OUTPUT_DIR)/coverage
RELEASE_DIR			:= $(OUTPUT_DIR)/release

PROJECT_FILES		:= $(shell find . -name *.go | grep -v _test)
PROJECT_MODULES	:= $(shell go list ./... | grep -v features)

DOCKER_IMAGE		:= hjhurtado/hello
COVER_FILE			:= $(COVER_DIR)/coverage.out
BINARY					:= hello
PLATFORMS				:= linux darwin windows
os							= $(word 1, $@)

.PHONY: clean docker-image $(PLATFORMS) release acceptance lint build

build: $(OUTPUT_DIR)/$(BINARY)

$(OUTPUT_DIR)/$(BINARY): $(PROJECT_FILES) $(OUTPUT_DIR)
	GOOS=linux GOARCH=amd64 go build -o $(OUTPUT_DIR)/$(BINARY) cmd/hello.go

test: lint $(COVER_DIR)
	go test -v -coverprofile=$(COVER_FILE) $(PROJECT_MODULES)

lint: $(GOLANGCI_LINT)
	$(GOLANGCI_LINT) run -v ./...

acceptance: $(GOLANG_GODOG) $(OUTPUT_DIR)/$(BINARY)
	cd features; HELLO_BINARY=../$(OUTPUT_DIR)/$(BINARY) $(GOLANG_GODOG) .

release: $(PLATFORMS) $(GOLANG_GHR)
	$(GOLANG_GHR) -t $${GITHUB_TOKEN} \
								-u $${CIRCLE_PROJECT_USERNAME} \
								-r $${CIRCLE_PROJECT_REPONAME} \
								-c $${CIRCLE_SHA1} \
								-delete \
								$${CIRCLE_TAG} $(RELEASE_DIR)

$(PLATFORMS): $(RELEASE_DIR)
	GOOS=$@ GOARCH=amd64 go build -o $(RELEASE_DIR)/$(BINARY)-$@-amd64 cmd/hello.go
	if [ "$@" = "linux" ]; then \
		cp $(RELEASE_DIR)/$(BINARY)-linux-amd64 $(DOCKER_DIR)/$(BINARY); \
	fi

docker-image:
	echo $${DOCKER_PASSWORD} | docker login -u $${DOCKER_USER} --password-stdin
	cd $(DOCKER_DIR); docker build -t $(DOCKER_IMAGE):latest .
	docker push $(DOCKER_IMAGE):latest
	if [ -n "$${CIRCLE_TAG}" ] ; then \
		docker image tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):$${CIRCLE_TAG}; \
		docker push $(DOCKER_IMAGE):$${CIRCLE_TAG}; \
	fi
	docker logout

clean:
	rm -rf $(OUTPUT_DIR)
	rm -f $(DOCKER_DIR)/$(BINARY)

$(COVER_DIR) $(RELEASE_DIR) $(OUTPUT_DIR):
	mkdir -p $@

$(GOLANGCI_LINT):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b $(BIN_DIR) v1.21.0

$(GOLANG_GODOG):
	go get -u github.com/DATA-DOG/godog/cmd/godog@v0.7.13

$(GOLANG_GHR):
	go get -u github.com/tcnksm/ghr
