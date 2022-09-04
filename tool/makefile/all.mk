.PHONY: clean format get upgrade outdated docker-push-stage docker-run-stage deploy-stage docker-logs-stage docker-push-prod docker-run-prod deploy-prod docker-logs-prod

install:
	@echo "Installing the app"
	@dart pub get
	@dart pub run build_runner build --delete-conflicting-outputs
	@dart format --line-length=80 .
	@dart format .
	
clean:
	@echo "Cleaning the project"
	@flutter clean

format:
	@echo "Formatting the code"
	@dart format -l 120 --fix .

upgrade: get
	@echo "Upgrading dependencies"
	@flutter pub upgrade

upgrade-major: get
	@echo "Upgrading dependencies --major-versions"
	@flutter pub upgrade --major-versions

codegen: get
	@echo "Running codegeneration"
	@flutter pub run build_runner build --delete-conflicting-outputs --release

build: codegen
	@echo "Building"
	@flutter build web --no-pub --release --no-source-maps --tree-shake-icons --pwa-strategy offline-first --web-renderer canvaskit --dart-define=FLUTTER_WEB_USE_SKIA=true

outdated:
	@flutter pub outdated

docker-build-stage:
	@echo "Build staging docker images"
	docker build --no-cache --force-rm --compress \
			--file ./docker/nginx.dockerfile \
			--tag registry.plugfox.dev/make-world-fe:stage .

docker-push-stage:
	@echo "Push staging docker images"
	docker push registry.plugfox.dev/make-world-fe:stage

docker-run-stage:
	@echo "Run staging docker images"
	docker run -d -p 8080:80 --name make-world-fe-stage registry.plugfox.dev/make-world-fe:stage

deploy-stage: docker-build-stage docker-push-stage
	@echo "Deploy staging into docker swarm"
	docker --log-level debug --host "ssh://dvmatyun@dvmatyun.ru" stack deploy --compose-file ./docker/make-world-fe-stage.stack.yml --orchestrator swarm --prune --with-registry-auth make-world-fe-stage

docker-logs-stage:
	@echo "Read logs from docker swarm release"
	docker --log-level debug --host "ssh://dvmatyun@dvmatyun.ru" service logs --no-task-ids -f -n all make-world-fe-stage_site

docker-build-prod:
	@echo "Build release docker images"
	docker build --no-cache --force-rm --compress \
			--file ./docker/make-world-fe.dockerfile \
			--tag registry.plugfox.dev/make-world-fe:prod .

docker-push-prod:
	@echo "Push release docker images"
	docker push registry.plugfox.dev/make-world-fe:prod

docker-run-prod:
	@echo "Run release docker images"
	docker run -d -p 8080:80 --name make-world-fe-prod registry.plugfox.dev/make-world-fe:prod

deploy-prod: docker-build-prod docker-push-prod
	@echo "Deploy release into docker swarm"
	docker --log-level debug --host "ssh://dvmatyun@dvmatyun.ru" stack deploy --compose-file ./docker/make-world-fe-prod.stack.yml --orchestrator swarm --prune --with-registry-auth make-world-fe-prod

docker-logs-prod:
	@echo "Read logs from docker swarm release"
	docker --log-level debug --host "ssh://dvmatyun@dvmatyun.ru" service logs --no-task-ids -f -n all make-world-fe-prod_site
