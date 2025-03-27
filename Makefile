app: gren.json $(shell find src -name "*.gren")
	gren make src/Main.gren

app-test: gren.json $(shell find src/Test -name "*.gren")
	gren make src/Test/Main.gren --output=app-test

.PHONY: server
server: app
	node app

.PHONY: test
test: app-test
	node app-test
