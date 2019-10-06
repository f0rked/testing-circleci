PROJECT_FILES = $(find . -name '*.go')

all: build

build: test
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build -o output/hello ./...

test: $(PROJECT_FILES)
	[ ! -d output ] && mkdir -p output/coverage
	GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go test -cover -coverprofile=output/coverage/coverage.out ./...

clean:
	rm -rf output
