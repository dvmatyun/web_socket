.PHONY: get

get:
	@dart pub get

pana: get
	@dart pub global activate pana
	@dart pub global run pana

deploy:
	@dart pub publish

deploy-test:
	@dart pub publish --dry-run