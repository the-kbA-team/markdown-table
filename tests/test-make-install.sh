#!/bin/sh
set -eu

cd "$(dirname "$0")"
export PATH="$(pwd)/support:$PATH"
export MOCK_LOG="$(pwd)/.make-install-log"
export LC_ALL=C
unset CA_CERT_FILE
test ! -e composer.json && test ! -e composer.lock && test ! -e "$MOCK_LOG" && test ! -e .make-install-error
trap 'rm -f composer.json composer.lock .make-install-log .make-install-error' 0
printf '%s\n' '{"config":{"platform":{"php":"7.2","ext-example":"1.0"},"sort-packages":true}}' > composer.json
original=$(cat composer.json)

run_install() {
    : > "$MOCK_LOG"
    status=0
    make -s -f ../Makefile install PHP_VERSION=8.3 "$@" 2>.make-install-error || status=$?
    test "$(cat composer.json)" = "$original"
    test ! -e composer.lock
    test -z "$(find . -maxdepth 1 -name '.composer-install-*' -print)"
}

run_install DEPENDENCIES_LOWEST=0
test "$status" = 0
! grep -q -- --prefer-lowest "$MOCK_LOG"
grep -q 'config --unset platform' "$MOCK_LOG"
run_install COMPOSER_NO_DEV=0
test "$status" = 0
! grep -q -- --no-dev "$MOCK_LOG"
run_install DEPENDENCIES_LOWEST=1
test "$status" = 0
grep -q -- --prefer-lowest "$MOCK_LOG"
run_install COMPOSER_NO_DEV=1
test "$status" = 0
grep -q 'remove --dev phpunit/phpunit --no-update' "$MOCK_LOG"
grep -q -- --no-dev "$MOCK_LOG"

export MOCK_COMPOSER_STATUS=17
run_install
test "$status" = 2
grep -q 'Error 17' .make-install-error
unset MOCK_COMPOSER_STATUS

export MOCK_CONFIG_STATUS=19
run_install
test "$status" = 2
grep -q 'Configuration failed' .make-install-error
grep -q 'Error 19' .make-install-error
! grep -q '^update' "$MOCK_LOG"
unset MOCK_CONFIG_STATUS

touch composer.lock
run_install PHP_VERSION=
test "$status" = 2
grep -q 'set PHP_VERSION' .make-install-error

touch composer.lock
run_install COMPOSER_CACHE_DIR=composer.json
test "$status" = 2

touch composer.lock
export MOCK_DOCKER_FAIL=1
run_install
test "$status" = 2
grep -q 'Error 42' .make-install-error
test ! -e vendor/bin/phpunit
if make -s -f ../Makefile test PHP_VERSION=8.3 2>.make-install-error; then
    echo 'Expected missing PHPUnit to fail.' >&2
    exit 1
fi
grep -q 'vendor/bin/phpunit is missing' .make-install-error
echo 'Make install regression checks passed.'
