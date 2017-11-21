################################################################################
# Makefile for PHP
################################################################################
SHELL := /bin/bash -o pipefail

# To override the variables in this section, define them in the project's
# Makefile before including this file.

ifeq ($(.DEFAULT_GOAL),)
.DEFAULT_GOAL := test
endif

# Arguments passed to "phpunit" or "peridot".
TEST_ARGS ?=

# The REQ and USE variables are used as pre-requisites for all targets that
# execute the project's PHP source, including tests.
#
# They can be used to specify additional build dependencies other than the .php
# source files, such as HTML assets, etc.
#
# REQ is used a "normal" pre-requisite, whereas USE is an "order-only"
# pre-requisite.
#
# See https://www.gnu.org/software/make/manual/html_node/Prerequisite-Types.html
REQ ?=
USE ?=

################################################################################
# Internal variables
################################################################################

# _SRC contains the paths to all PHP source files.
_SRC ?= $(shell find ./src -name '*.php' 2> /dev/null)

# _TEST_SRC contains the paths to all test files.
_TEST_SRC := $(shell find ./test -type f 2> /dev/null)

# _BINS contains the names of binaries (files under ./bin)
_BINS ?= $(notdir $(shell find bin -mindepth 1 -maxdepth 1 -type f 2>/dev/null))

# TODO
# DOCKER_REQ ?= $(addprefix artifacts/build/release/linux/amd64/,$(_BINS))

################################################################################
# Commands (Phony Targets)
################################################################################

# Run all tests.
.PHONY: test
test: vendor $(REQ) | $(USE)
ifeq (,$(wildcard peridot.php))
	php -c test/etc/php.ini vendor/bin/phpunit $(TEST_ARGS)
else
	php -c test/etc/php.ini vendor/bin/peridot $(TEST_ARGS)
endif

# Remove all files that match the patterns .gitignore.
.PHONY: clean-all
clean-all:: clean
	rm -rf ./vendor

# Remove files that match the patterns .gitignore, excluding the vendor folder.
.PHONY: clean
clean::
	@git check-ignore ./* | grep -v ^./vendor | xargs -t -n1 rm -rf

.PHONY: clean-coverage
clean-coverage:
	rm -rf artifacts/tests/coverage

# Generate an HTML code coverage report.
.PHONY: coverage
coverage: artifacts/tests/coverage/index.html

# Generate an HTML code coverage report and open it in the browser.
# TODO: This command only works on OSX.
.PHONY: coverage-open
coverage-open: artifacts/tests/coverage/index.html
	open "$<"

# Perform code linting, syntax formatting, etc.
.PHONY: lint
lint: artifacts/logs/lint artifacts/logs/composer-validate

# Perform pre-commit checks.
.PHONY: prepare
prepare: lint test

# Run the CI build.
.PHONY: ci
ci: lint artifacts/tests/coverage/clover.xml

.PHONY:
usage::
	@cat artifacts/make/php/usage.txt
	@echo

################################################################################
# File Targets
################################################################################

.DELETE_ON_ERROR:
.PHONY: FORCE

COMPOSER := $(shell which composer)

ifeq (,${COMPOSER})

COMPOSER := artifacts/composer/composer.phar

$(COMPOSER):
	@echo "Composer not found locally, installing from source"
	@mkdir -p "$(@D)"
	curl --create-dirs '-#Lo' "$(@D)/expected.sig" "https://composer.github.io/installer.sig"
	curl --create-dirs '-#Lo' "$(@D)/installer" "https://getcomposer.org/installer"
	php -r "file_put_contents('$(@D)/actual.sig', hash_file('SHA384', '$(@D)/installer') . PHP_EOL);"
	cmp "$(@D)/expected.sig" "$(@D)/actual.sig"
	php "$(@D)/installer" --force --install-dir "$(@D)"

endif

vendor: composer.lock | $(COMPOSER)
	$(COMPOSER) install

composer.lock: composer.json | $(COMPOSER)
	$(COMPOSER) update

composer.json: | $(COMPOSER)
	$(COMPOSER) init --no-interaction

ifeq (,$(wildcard peridot.php))

artifacts/tests/coverage/index.html: $(_SRC) $(_TEST_SRC) $(REQ) phpunit.coverage.xml | vendor $(USE)
	phpdbg -c test/etc/php.ini -qrr vendor/bin/phpunit -c phpunit.coverage.xml $(TEST_ARGS) --coverage-html=$(@D)

artifacts/tests/coverage/clover.xml: $(_SRC) $(_TEST_SRC) $(REQ) phpunit.coverage.xml | vendor $(USE)
	phpdbg -c test/etc/php.ini -qrr vendor/bin/phpunit -c phpunit.coverage.xml $(TEST_ARGS) --coverage-clover=$@

else

artifacts/tests/coverage/index.html: $(_SRC) $(_TEST_SRC) $(REQ) peridot.php | vendor $(USE)
	phpdbg -c test/etc/php.ini -qrr vendor/bin/peridot $(TEST_ARGS) --reporter html-code-coverage --code-coverage-path=$(@D)

artifacts/tests/coverage/clover.xml: $(_SRC) $(_TEST_SRC) $(REQ) peridot.php | vendor $(USE)
	phpdbg -c test/etc/php.ini -qrr vendor/bin/peridot $(TEST_ARGS) --reporter clover-code-coverage --code-coverage-path=$@

endif

artifacts/logs/lint: vendor $(_SRC)
	@mkdir -p "$(@D)"
	vendor/bin/php-cs-fixer fix | tee "$@"

artifacts/logs/composer-validate: composer.json | $(COMPOSER)
	@mkdir -p "$(@D)"
	$(COMPOSER) validate --no-check-publish | tee "$@"
