#
BIN_DIR				:= $(GOPATH)/bin
GOLANGCI_LINT	:= $(BIN_DIR)/golangci-lint
GOLANG_GODOG	:= $(BIN_DIR)/godog
GOLANG_GHR		:= $(BIN_DIR)/ghr
PROJECT_FILES	:= $(shell find . -name *.go)
DOCKER_IMAGE	:= hjhurtado/hello
DOCKER_DIR		:= docker
OUTPUT_DIR		:= output
COVER_DIR			:= $(OUTPUT_DIR)/coverage
COVER_FILE		:= $(COVER_DIR)/coverage.out
RELEASE_DIR		:= $(OUTPUT_DIR)/release
BINARY				:= hello
PLATFORMS			:= linux darwin windows
os						= $(word 1, $@)

.PHONY: clean image $(PLATFORMS) release acceptance lint test build

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
	cd features; HELLO_BINARY=../$(OUTPUT_DIR)/$(BINARY) $(GOLANG_GODOG) .

release: $(PLATFORMS) $(GOLANG_GHR)
	$(GOLANG_GHR) -t $${GITHUB_TOKEN} \
								-u $${CIRCLE_PROJECT_USERNAME} \
								-r $${CIRCLE_PROJECT_REPONAME} \
								-c $${CIRCLE_SHA1} \
								-delete \
								$${CIRCLE_TAG} $(RELEASE_DIR)

$(PLATFORMS):
	mkdir -p $(RELEASE_DIR)
	GOOS=$(os) GOARCH=amd64 go build -o $(RELEASE_DIR)/$(BINARY)-$(os)-amd64 cmd/hello.go

image:
	cp $(RELEASE_DIR)/$(BINARY)-linux-amd64 $(DOCKER_DIR)/$(BINARY)
	echo $${DOCKER_PASSWORD} | docker login -u $${DOCKER_USER} --password-stdin
	cd $(DOCKER_DIR); docker build -t $(DOCKER_IMAGE):latest .
	docker push $(DOCKER_IMAGE):latest
	if [ -n "$${CIRCLE_TAG}" ] ; then \
		docker image tag $(DOCKER_IMAGE):latest $(DOCKER_IMAGE):$${CIRCLE_TAG}; \
		docker push $(DOCKER_IMAGE):$${CIRCLE_TAG}; \
	fi
	docker logout

clean:
	rm -rf output
	rm -f $(DOCKER_DIR)/$(BINARY)

$(GOLANGCI_LINT):
	curl -sfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s -- -b $(BIN_DIR) v1.21.0

$(GOLANG_GODOG):
	go get -u github.com/DATA-DOG/godog/cmd/godog

$(GOLANG_GHR):
	go get -u github.com/tcnksm/ghr
