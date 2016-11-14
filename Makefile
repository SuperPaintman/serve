CRYSTAL_BIN ?= $(shell which crystal)
SERVE_BIN ?= $(shell which serve)
PREFIX ?= /usr/local

all: clean build

build:
	$(CRYSTAL_BIN) deps
	$(CRYSTAL_BIN) build --release -o bin/serve src/serve/bootstrap.cr $(CRFLAGS)

clean:
	rm -f ./bin/serve

test:
	$(CRYSTAL_BIN) spec --verbose

spec: test

install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/serve $(PREFIX)/bin

reinstall: build
	cp -rf ./bin/serve $(SERVE_BIN)

.PHONY: all build clean test spec install reinstall
