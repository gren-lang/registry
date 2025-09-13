dist/app: node_modules gren.json $(shell find src -name "*.gren")
	gren make Main --output=dist/app

dist/test: dist/app
	gren make Test.Main --output=dist/test

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
