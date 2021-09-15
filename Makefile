VERSION := $(shell yq e ".version" manifest.yaml)

.DELETE_ON_ERROR:

all: verify
	
verify: mastodon.s9pk
	embassy-sdk verify mastodon.s9pk

mastodon.s9pk: manifest.yaml assets/compat/* image.tar instructions.md
	embassy-sdk pack

install: mastodon.s9pk
	embassy-cli package install mastodon.s9pk

image.tar: Dockerfile docker_entrypoint.sh nginx.conf mastodon
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --tag start9/mastodon/main:$(VERSION) --platform=linux/arm64 -o type=docker,dest=image.tar .
