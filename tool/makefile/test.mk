.PHONY: test

test: get
	@dart run coverage:test_with_coverage -fb -o coverage -- \
		--concurrency=6 --coverage=./coverage --reporter=expanded test/isolation_test.dart