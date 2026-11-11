SHELL := /bin/sh
.DEFAULT_GOAL := help

COMPOSER_IMAGE     := composer:2
COMPOSER_CACHE_DIR := $(HOME)/.cache/composer
DOCKER_USER        := --user "$$(id -u)":"$$(id -g)"
DOCKER_MOUNT       := --volume "$$(pwd)":/app --workdir /app

ifeq ($(DEPENDENCIES_LOWEST),1)
COMPOSER_LOWEST := --prefer-lowest
endif

ifeq ($(COMPOSER_NO_DEV),1)
COMPOSER_NO_DEV_OPTION := --no-dev
# Composer still resolves require-dev with --no-dev, so remove PHPUnit from the temporary manifest.
COMPOSER_NO_DEV_PREPARE := composer remove --dev phpunit/phpunit --no-update --no-interaction &&
endif

ifdef CA_CERT_FILE
CA_MOUNT := --volume "$(CA_CERT_FILE)":/usr/local/share/ca-certificates/extra-ca.crt:ro
CA_ENV := --env COMPOSER_CAFILE=/usr/local/share/ca-certificates/extra-ca.crt
endif

.PHONY: help clean check-php-version install test lint audit validate

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

clean: ## Remove vendor/, composer.lock, and PHPUnit cache
	rm -rf vendor composer.lock .phpunit.result.cache

check-php-version:
	@if [ -z "$(PHP_VERSION)" ]; then \
		echo "Error: set PHP_VERSION, e.g. 'make install PHP_VERSION=8.4'." >&2; \
		exit 1; \
	fi

install: ## Resolve dependencies for PHP_VERSION without retaining composer.lock
	@manifest=".composer-install-$$$$.json"; \
	lock="$${manifest%.json}.lock"; \
	owned=; \
	trap 'if [ -n "$$owned" ]; then rm -f "$$manifest" "$$lock"; fi; rm -f composer.lock' 0; \
	trap 'exit 1' HUP INT TERM; \
	$(MAKE) --no-print-directory -f "$(firstword $(MAKEFILE_LIST))" check-php-version || exit $$?; \
	mkdir -p "$(COMPOSER_CACHE_DIR)" || exit $$?; \
	( set -C; : > "$$manifest" ) 2>/dev/null || { echo "Error: cannot create $$manifest" >&2; exit 1; }; \
	owned=1; \
	cp composer.json "$$manifest" || exit $$?; \
	docker run --rm --init $(DOCKER_USER) \
		--env HTTP_PROXY --env HTTPS_PROXY --env NO_PROXY \
		--env http_proxy --env https_proxy --env no_proxy \
		--env COMPOSER_CACHE_DIR=/composer-cache \
		--env "COMPOSER=$$manifest" \
		--volume "$(COMPOSER_CACHE_DIR)":/composer-cache \
		$(CA_MOUNT) $(CA_ENV) \
		$(DOCKER_MOUNT) \
		$(COMPOSER_IMAGE) sh -c '\
			composer config --unset platform && \
			$(COMPOSER_NO_DEV_PREPARE) \
			composer config platform.php "$(PHP_VERSION)" && \
			composer update $(COMPOSER_LOWEST) $(COMPOSER_NO_DEV_OPTION) --prefer-dist --no-interaction --no-progress'

test: check-php-version ## Run PHPUnit with the selected host PHP version
	@test -x vendor/bin/phpunit || { echo "Error: vendor/bin/phpunit is missing; run make install with dev dependencies." >&2; exit 1; }
	php vendor/bin/phpunit $(PHPUNIT_ARGS)

lint: check-php-version ## Syntax-check PHP files in src/ and tests/
	find src tests -type f -name '*.php' -print0 | xargs -0 -n1 php -l

audit: ## Check dependencies for known vulnerabilities
	docker run --rm --init $(DOCKER_USER) \
		--env HTTP_PROXY --env HTTPS_PROXY --env NO_PROXY \
		--env http_proxy --env https_proxy --env no_proxy \
		$(CA_MOUNT) $(CA_ENV) $(DOCKER_MOUNT) \
		$(COMPOSER_IMAGE) composer audit

validate: ## Validate composer.json
	docker run --rm --init $(DOCKER_USER) $(DOCKER_MOUNT) \
		$(COMPOSER_IMAGE) composer validate --strict
