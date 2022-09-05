.PHONY: test format pana analyze metrics

test: get
	@dart run coverage:test_with_coverage -fb -o coverage -- \
		--concurrency=6 --coverage=./coverage --reporter=expanded test/isolation_test.dart

format:
	@echo "Formatting the code"
	@dart format -l 80 --fix .
	@dart fix --apply

pana: get
	@dart pub global activate pana
	@dart pub global run pana

analyze: get
	@dart format --set-exit-if-changed -l 80 -o none .
	@dart analyze --fatal-infos --fatal-warnings lib

metrics: get
	@dart pub global activate dart_code_metrics
	@dart pub global run dart_code_metrics:metrics analyze lib
	@dart pub global run dart_code_metrics:metrics check-unused-code lib
	@dart pub global run dart_code_metrics:metrics check-unused-files lib
	@dart pub global run dart_code_metrics:metrics check-unnecessary-nullable lib