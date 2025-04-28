dist/app: node_modules gren.json $(shell find src -name "*.gren")
	gren make src/Main.gren --output=dist/app

dist/test: gren.json $(shell find src/Test -name "*.gren")
	gren make src/Test/Main.gren --output=dist/test

node_modules: package.json package-lock.json
	npm install

.PHONY: db
db: node_modules
	# TODO: get db url from env
	npx ws4sql --quick-db=db/local.db

.PHONY: server
server: dist/app
	node dist/app

.PHONY: test
test: dist/test
	node dist/test
