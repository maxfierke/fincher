CRYSTAL_BIN ?= $(shell which crystal)
TYPHAR_BIN  ?= $(shell which typhar)
PREFIX      ?= /usr/local

all: build
build:
	mkdir -p bin
	$(CRYSTAL_BIN) build -o bin/typhar src/typhar.cr $(CRFLAGS)
clean:
	rm -f ./bin/typhar
test: build
	$(CRYSTAL_BIN) spec
install: build
	mkdir -p $(PREFIX)/bin
	cp ./bin/typhar $(PREFIX)/bin
reinstall: build
	cp ./bin/typhar $(TYPHAR_BIN) -rf