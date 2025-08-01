SHELL := /bin/bash
MAKEFLAGS := --jobs=$(shell nproc)
PKGNAME := scholkit

# the "sk" toolkit binaries to build
TARGETS := sk-cat \
		   sk-cdx \
		   sk-cluster \
		   sk-convert \
		   sk-crossref-snapshot \
		   sk-feed \
		   sk-id \
		   sk-norm \
		   sk-oai-records \
		   sk-oai-dctojsonl \
	       sk-snapshot

.PHONY: all
all: $(TARGETS)

# CGO_ENABLED: libc.so.6: version `GLIBC_2.34' not found
%: cmd/%/main.go
	CGO_ENABLED=0 go build -o $@ $<

.PHONY: test
test:
	go test -v -cover ./...

.PHONY: clean
clean:
	rm -f $(TARGETS)
	rm -f $(PKGNAME)_*deb
	rm -rf packaging/deb/$(PKGNAME)/usr/*

.PHONY: update-all-deps
update-all-deps:
	go get -u -v ./... && go mod tidy

.PHONY: deb
deb: $(TARGETS)
	mkdir -p packaging/deb/$(PKGNAME)/usr/local/bin
	cp $(TARGETS) packaging/deb/$(PKGNAME)/usr/local/bin
	mkdir -p packaging/deb/$(PKGNAME)/usr/lib/systemd/system
	cd packaging/deb && fakeroot dpkg-deb -Zzstd --build $(PKGNAME) .
	mv packaging/deb/$(PKGNAME)_*.deb .

