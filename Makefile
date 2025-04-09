dist/app.js: node_modules gren.json $(shell find src -name "*.gren")
	gren make src/Main.gren --output=dist/app.js

dist/test: gren.json $(shell find src/Test -name "*.gren")
	gren make src/Test/Main.gren --output=dist/test

node_modules: package.json package-lock.json
	npm install

.PHONY: server
server: dist/app.js
	node src/server.js

.PHONY: test
test: dist/test
	node dist/test
