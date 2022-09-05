.PHONY: get upgrade upgrade-major outdated deploy deploy-test

get:
	@dart pub get

upgrade: get
	@echo "Upgrading dependencies"
	@dart pub upgrade

upgrade-major: get
	@echo "Upgrading dependencies --major-versions"
	@dart pub upgrade --major-versions

outdated:
	@dart pub outdated

deploy:
	@dart pub publish

deploy-test:
	@dart pub publish --dry-run