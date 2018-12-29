CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN  ?= $(shell which shards)
FINCHER_BIN ?= $(shell which fincher)
PREFIX      ?= /usr/local
SOURCES      = src/*.cr src/**/*.cr

all: build
build: deps $(SOURCES)
	mkdir -p bin
	$(CRYSTAL_BIN) build --debug -o bin/fincher src/cli.cr $(CRFLAGS)
release: deps $(SOURCES)
	mkdir -p dist
	$(CRYSTAL_BIN) build --release -o dist/fincher src/cli.cr $(CRFLAGS)
deps:
	$(SHARDS_BIN) check || $(SHARDS_BIN) install
clean:
	rm -f ./bin/fincher*
	rm -rf ./dist
test: build
	$(CRYSTAL_BIN) spec
spec: test
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/fincher $(PREFIX)/bin
reinstall: build
	cp ./bin/fincher $(FINCHER_BIN) -rf
