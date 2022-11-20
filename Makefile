PKG_ID := $(shell yq e ".id" manifest.yaml)
PKG_VERSION := $(shell yq e ".version" manifest.yaml)
TS_FILES := $(shell find ./ -name \*.ts)
DOCKER_CUR_ENGINE := $(shell docker buildx ls | grep "*" | awk '{print $$1;}')

.DELETE_ON_ERROR:

all: verify

clean:
	rm -f image.tar
	rm -f $(PKG_ID).s9pk
	rm -f scripts/*.js
	rm -rf docker-images
	
verify: $(PKG_ID).s9pk
	@embassy-sdk verify s9pk $(PKG_ID).s9pk
	@echo " Done!"
	@echo "   Filesize: $(shell du -h $(PKG_ID).s9pk) is ready"

$(PKG_ID).s9pk: manifest.yaml scripts/embassy.js docker-images/aarch64.tar docker-images/x86_64.tar instructions.md
	@if ! [ -z "$(ARCH)" ]; then cp docker-images/$(ARCH).tar image.tar; echo "* image.tar compiled for $(ARCH)"; fi
	embassy-sdk pack

install: $(PKG_ID).s9pk
	embassy-cli package install $(PKG_ID).s9pk

docker-images/aarch64.tar: Dockerfile docker_entrypoint.sh reset_first_user.sh check-federation.sh nginx.conf mastodon pg-migrate/*
	mkdir -p docker-images
	docker buildx use default
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --build-arg PLATFORM=arm64 --tag start9/mastodon/main:$(PKG_VERSION) --platform=linux/arm64 .
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --build-arg PLATFORM=arm64 --tag start9/mastodon/pg-migrate:$(PKG_VERSION) --platform=linux/arm64 -f pg-migrate/Dockerfile .
	docker buildx use $(DOCKER_CUR_ENGINE)
	docker save -o docker-images/aarch64.tar start9/mastodon/main:$(PKG_VERSION) start9/mastodon/pg-migrate:$(PKG_VERSION)

docker-images/x86_64.tar: Dockerfile docker_entrypoint.sh reset_first_user.sh check-federation.sh nginx.conf mastodon pg-migrate/*
	mkdir -p docker-images
	docker buildx use default
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --build-arg PLATFORM=amd64 --tag start9/mastodon/main:$(PKG_VERSION) --platform=linux/amd64 .
	DOCKER_CLI_EXPERIMENTAL=enabled docker buildx build --build-arg PLATFORM=amd64 --tag start9/mastodon/pg-migrate:$(PKG_VERSION) --platform=linux/amd64 -f pg-migrate/Dockerfile .
	docker buildx use $(DOCKER_CUR_ENGINE)
	docker save -o docker-images/x86_64.tar start9/mastodon/main:$(PKG_VERSION) start9/mastodon/pg-migrate:$(PKG_VERSION)

scripts/embassy.js: $(TS_FILES)
	deno bundle scripts/embassy.ts scripts/embassy.js
