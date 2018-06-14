VERSION := 0.0.1
PKG := diseval
CURRENT_TARGET := diseval.so

check:
	@shellcheck -x bin/steps/*
	@shellcheck -x bin/build
	@shellcheck -x bin/utils/*

bin/docklint:
	wget https://github.com/hadolint/hadolint/releases/download/v1.6.5/hadolint-Linux-x86_64 -O bin/docklint
	chmod +x bin/docklint

bin/container-structure-test:
	wget https://storage.googleapis.com/container-structure-test/latest/container-structure-test-linux-amd64 -O bin/container-structure-test
	chmod +x bin/container-structure-test

build:
	docker build -t diseval .
	docker run --name diseval diseval /bin/true
	docker cp diseval:/source/modules/diseval.so ./diseval.so
	docker rm diseval

structure: bin/container-structure-test
	bin/container-structure-test test --image diseval --config ./image_test.yaml

tests: check lint structure

lint: bin/docklint
	bin/docklint Dockerfile

run: 
	docker run -it diseval /bin/bash

package: build
	curl -L https://github.com/dz0ny/cdeb/releases/download/v1.0.0/cdeb-`uname -s`-`uname -m` > cdeb
	chmod +x cdeb
	rm -rf .packaging/root/usr/lib/php/20170718/
	mkdir -p .packaging/root/usr/lib/php/20170718/
	cp $(CURRENT_TARGET) .packaging/root/usr/lib/php/20170718/$(CURRENT_TARGET)
	sed -i "s/REP_VERSION/$(VERSION)/" .packaging/debian/control
	./cdeb .packaging/root .packaging/debian $(PKG)_$(VERSION).deb

package_cloud:
	gem install package_cloud

publish: package package_cloud
	package_cloud push niteoweb/ebn-stack/ubuntu/trusty $(shell pwd)/$(PKG)_$(VERSION).deb