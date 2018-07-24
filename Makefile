# Copyright (c) 2017-2018 Martin Donath <martin.donath@squidfunk.com>

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

all: lint clean | build test

# -----------------------------------------------------------------------------
# Prerequisites
# -----------------------------------------------------------------------------

# Install dependencies
node_modules:
	npm install

# -----------------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------------

# Distribution files
dist: $(shell find src) tsconfig.json
	$(shell npm bin)/tsc -p tsconfig.json

# -----------------------------------------------------------------------------
# Rules
# -----------------------------------------------------------------------------

# Build distribution files
build: node_modules | dist

# Clean distribution files
clean:
	rm -rf .nyc_output coverage dist

# Lint source files
lint: node_modules
	$(shell npm bin)/tslint -p tsconfig.json "src/**/*.ts"
	$(shell npm bin)/tslint -p tests/tsconfig.json "tests/**/*.ts"

# Execute unit tests
test: node_modules
	@ NODE_ENV=test $(shell npm bin)/nyc \
		$(shell npm bin)/ts-node -r tsconfig-paths/register \
			--project tests/tsconfig.json --files tests \
				"suites/unit/**/*.spec.ts"

# Execute unit tests in watch mode
watch: node_modules
	@ NODE_ENV=development $(shell npm bin)/nodemon --quiet \
		--watch src --watch tests --ext json,ts --exec \
		$(shell npm bin)/ts-node -r tsconfig-paths/register \
			--project tests/tsconfig.json --files tests \
				"suites/unit/**/*.spec.ts"

# -----------------------------------------------------------------------------

# Special targets
.PHONY: .FORCE build clean lint test watch
.FORCE:
