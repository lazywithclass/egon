test:
	./node_modules/.bin/mocha --compilers coffee:coffee-script/register --reporter spec --recursive test --stack_trace_limit 10

.PHONY: test
