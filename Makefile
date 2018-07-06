CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN  ?= $(shell which shards)
TYPHAR_BIN  ?= $(shell which typhar)
PREFIX      ?= /usr/local

all: build
build: deps
	mkdir -p bin
	$(CRYSTAL_BIN) build --debug -o bin/typhar src/cli.cr $(CRFLAGS)
deps:
	$(SHARDS_BIN) check || $(SHARDS_BIN) install
clean:
	rm -f ./bin/typhar
test: build
	$(CRYSTAL_BIN) spec
spec: test
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/typhar $(PREFIX)/bin
reinstall: build
	cp ./bin/typhar $(TYPHAR_BIN) -rf
