CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN  ?= $(shell which shards)
FINCHER_BIN ?= $(shell which fincher)
PREFIX      ?= /usr/local
RELEASE     ?=
STATIC      ?=
SOURCES      = src/*.cr src/**/*.cr

override CRFLAGS += --warnings=all --error-trace $(if $(RELEASE),--release ,--debug )$(if $(STATIC),--static )$(if $(LDFLAGS),--link-flags="$(LDFLAGS)" )

.PHONY: all
all: build

bin/fincher: deps $(SOURCES)
	mkdir -p bin
	$(CRYSTAL_BIN) build -o bin/fincher src/cli.cr $(CRFLAGS)

.PHONY: build
build: bin/fincher

.PHONY: deps
deps:
	$(SHARDS_BIN) check || $(SHARDS_BIN) install

.PHONY: clean
clean:
	rm -f ./bin/fincher*
	rm -rf ./dist

.PHONY: test
test: deps $(SOURCES)
	$(CRYSTAL_BIN) spec $(CRFLAGS)

.PHONY: spec
spec: test

.PHONY: install
install: bin/fincher
	mkdir -p $(PREFIX)/bin
	cp ./bin/fincher $(PREFIX)/bin

.PHONY: reinstall
reinstall: bin/fincher
	cp ./bin/fincher $(FINCHER_BIN) -rf
