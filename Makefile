VERSION := $(shell yq e ".version" manifest.yaml)
DOCKER_CUR_ENGINE := $(shell docker buildx ls | grep "*" | awk '{print $$1;}')

.DELETE_ON_ERROR:

all: verify
	
verify: mastodon.s9pk
	embassy-sdk verify mastodon.s9pk

mastodon.s9pk: manifest.yaml assets/compat/* image.tar instructions.md
	embassy-sdk pack

install: mastodon.s9pk
	embassy-cli package install mastodon.s9pk

image.tar: Dockerfile docker_entrypoint.sh reset_first_user.sh check-federation.sh nginx.conf mastodon pg-migrate/*
	docker buildx use default
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/mastodon/main:$(VERSION) --platform=linux/arm64 .
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/mastodon/pg-migrate:$(VERSION) --platform=linux/arm64 -f pg-migrate/Dockerfile .
	docker buildx use $(DOCKER_CUR_ENGINE)
	docker save -o image.tar start9/mastodon/main:$(VERSION) start9/mastodon/pg-migrate:$(VERSION)
