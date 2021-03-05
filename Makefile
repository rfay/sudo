# Makefile for drud/sudo - Windows sudo, forked from mattn/sudo

GOTMP=.gotmp
SHELL = /bin/bash

VERSION := $(shell git describe --tags --always --dirty)

Version ?= $(VERSION)
VERSION_VARIABLES ?= Version

DEFAULT_BUILD=windows_amd64
build: $(DEFAULT_BUILD)

BUILD_OS = $(shell go env GOHOSTOS)
BUILD_ARCH = $(shell go env GOHOSTARCH)
VERSION_LDFLAGS=-X 'main.Version=$(VERSION)'
LDFLAGS=-extldflags -static $(VERSION_LDFLAGS)

windows_amd64: $(GOTMP)/bin/windows_amd64/sudo.exe
windows_arm64: $(GOTMP)/bin/windows_arm64/sudo.exe
# windows_arm64 is not yet supported in go v1.16, but will be in v1.17
TARGETS=$(GOTMP)/bin/windows_amd64/sudo.exe $(GOTMP)/bin/windows_arm64/sudo.exe
$(TARGETS): *.go
	@echo "building $@";
	@#echo "LDFLAGS=$(LDFLAGS)";
	@rm -f $@
	@export TARGET=$(word 3, $(subst /, ,$@)) && \
	export GOOS="$${TARGET%_*}" && \
	export GOARCH="$${TARGET#*_}" && \
	mkdir -p $(GOTMP)/{.cache,pkg,src,bin/$$TARGET} && \
	chmod 777 $(GOTMP)/{.cache,pkg,src,bin/$$TARGET} && \
	GOOS=$$GOOS GOARCH=$$GOARCH go build -o $(GOTMP)/bin/$$TARGET -installsuffix static -ldflags " $(LDFLAGS) "

windows_amd64_signed: $(GOTMP)/bin/windows_amd64/sudo.$(VERSION).exe
$(GOTMP)/bin/windows_amd64/sudo.$(VERSION).exe:  $(GOTMP)/bin/windows_amd64/sudo.exe
	@if [ -z "$(DDEV_WINDOWS_SIGNING_PASSWORD)" ] ; then echo "Skipping signing, no DDEV_WINDOWS_SIGNING_PASSWORD provided"; else echo "Signing $@..." && mv $< $<.unsigned && osslsigncode sign -pkcs12 certfiles/drud_cs.p12  -n "sudo for windows" -i https://ddev.com -in $<.unsigned -out $@ -t http://timestamp.digicert.com -pass $(DDEV_WINDOWS_SIGNING_PASSWORD); fi

test:
	go test -v ./...

clean:
	rm -rf $(GOTMP)