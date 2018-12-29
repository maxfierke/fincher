CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN  ?= $(shell which shards)
FINCHER_BIN  ?= $(shell which fincher)
PREFIX      ?= /usr/local

all: build
build: deps
	mkdir -p bin
	$(CRYSTAL_BIN) build --debug -o bin/fincher src/cli.cr $(CRFLAGS)
deps:
	$(SHARDS_BIN) check || $(SHARDS_BIN) install
clean:
	rm -f ./bin/fincher
test: build
	$(CRYSTAL_BIN) spec
spec: test
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/fincher $(PREFIX)/bin
reinstall: build
	cp ./bin/fincher $(FINCHER_BIN) -rf
