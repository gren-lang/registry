dist/app: gren.json gren_packages $(shell find src -name "*.gren")
	gren make Main --output=dist/app

dist/test: dist/app
	gren make Test.Main --output=dist/test

gren_packages: gren.json
	gren package install

.PHONY: server
server: dist/app
	node dist/app

.PHONY: test
test: dist/test
	node dist/test
