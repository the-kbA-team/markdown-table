SHELL := /bin/sh
.DEFAULT_GOAL := help

COMPOSER_IMAGE     := composer:2
COMPOSER_CACHE_DIR := $(HOME)/.cache/composer
DOCKER_USER        := --user "$$(id -u)":"$$(id -g)"
DOCKER_MOUNT       := --volume "$$(pwd)":/app --workdir /app

ifdef DEPENDENCIES_LOWEST
COMPOSER_LOWEST := --prefer-lowest
endif

ifdef COMPOSER_NO_DEV
COMPOSER_NO_DEV_OPTION := --no-dev
endif

ifdef CA_CERT_FILE
CA_MOUNT := --volume "$(CA_CERT_FILE)":/usr/local/share/ca-certificates/extra-ca.crt:ro
CA_TRUST_CMD := update-ca-certificates >/dev/null &&
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

install: check-php-version ## Resolve dependencies for PHP_VERSION without retaining composer.lock
	@mkdir -p "$(COMPOSER_CACHE_DIR)"
	@set +e; \
	docker run --rm --init $(DOCKER_USER) \
		--env HTTP_PROXY --env HTTPS_PROXY --env NO_PROXY \
		--env COMPOSER_CACHE_DIR=/composer-cache \
		--volume "$(COMPOSER_CACHE_DIR)":/composer-cache \
		$(CA_MOUNT) \
		$(DOCKER_MOUNT) \
		$(COMPOSER_IMAGE) sh -c '\
			$(CA_TRUST_CMD) \
			composer config platform.php "$(PHP_VERSION)" && \
			composer update $(COMPOSER_LOWEST) $(COMPOSER_NO_DEV_OPTION) --prefer-dist --no-interaction --no-progress; \
			status=$$?; \
			composer config --unset platform.php >/dev/null 2>&1 || true; \
			if grep -Eq \"config\"[[:space:]]*:[[:space:]]*\{[[:space:]]*\} composer.json; then composer config --unset config >/dev/null 2>&1 || true; fi; \
			rm -f composer.lock; \
			exit $$status'; \
	status=$$?; \
	rm -f composer.lock; \
	exit $$status

test: check-php-version ## Run PHPUnit with the selected host PHP version
	php vendor/bin/phpunit

lint: check-php-version ## Syntax-check PHP files in src/ and tests/
	find src tests -type f -name '*.php' -print0 | xargs -0 -n1 php -l

audit: ## Check dependencies for known vulnerabilities
	docker run --rm --init $(DOCKER_USER) \
		--env HTTP_PROXY --env HTTPS_PROXY --env NO_PROXY \
		$(CA_MOUNT) $(DOCKER_MOUNT) \
		$(COMPOSER_IMAGE) sh -c '$(CA_TRUST_CMD) composer audit'

validate: ## Validate composer.json
	docker run --rm --init $(DOCKER_USER) $(DOCKER_MOUNT) \
		$(COMPOSER_IMAGE) composer validate --strict
