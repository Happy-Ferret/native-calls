# Warning: setting these might break the tests, which currently have hardcoded links:
# You'll need to change the files below to fix this:
### test/CPPTestsSpec.js - Change the testingModule src.
### scripts/NaClConfig.js - Change the CONFIG and TOOLCHAIN properties.


TOOLCHAIN ?= pnacl
CONFIG ?= Release


export TOOLCHAIN
export CONFIG


mkfile_path = $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir = $(patsubst %/,%,$(dir $(mkfile_path)))

RPCLIB_DIR = cpp
TEST_CODE_DIR = test/cpp
EETEST_CODE_DIR = test/e2e

# Used to pipe stdout. useful for gtest output.
NACL_EXE_STDOUT ?= ${current_dir}/nacl_std_out.log

# Used to easily run npm module binaries (e.g. karma)
NM_BIN_PATH := ${current_dir}/node_modules/.bin
RJS_BIN := ./node_modules/requirejs/bin/r.js
KARMA_BIN := ./node_modules/karma/bin/karma
KARMA_START := $(KARMA_BIN) start
KARMA_WATCH_ARGS := --client.args=$(TOOLCHAIN) --client.args=$(CONFIG)
KARMA_RUN_ARGS := $(KARMA_WATCH_ARGS) --single-run
KARMA_CPP_CONF := karma-cpp.conf.js
KARMA_BENCH_CONF := karma-bench.conf.js
KARMA_JS_CONF := karma-js.conf.js
KARMA_EE_CONF := karma-e2e.conf.js

all: .PHONY

.PHONY: $(NM_BIN_PATH) libs tests eetests demos

#install
install: $(NM_BIN_PATH) js
	@echo "Installing libNativeCalls to $(NACL_SDK_ROOT)"
	@$(MAKE) -C $(RPCLIB_DIR) TOOLCHAIN=all CONFIG=Release -s > /dev/null || echo "Failed. Try make libs TOOLCHAIN=all"
	@$(MAKE) -C $(RPCLIB_DIR) TOOLCHAIN=all CONFIG=Debug -s > /dev/null || echo "Failed. Try make libs TOOLCHAIN=all"
	@echo "Installing pprpcgen globally"
	@npm install -g ./ --loglevel silent > /dev/null 2>&1 && echo "pprpcgen installed." || echo "pprcpgen installation failed. You may need sudo."

# anything that needs an npm module will need to install packages
$(NM_BIN_PATH):
	@npm install

$(KARMA_BIN) $(RJS_BIN):
	@npm install

# Make each part
js:
	@$(RJS_BIN) -o scripts/build/build.require.js > /dev/null 2>&1 && echo "NativeCalls.js built" || echo "Failed to build NativeCalls.js"

libs:
	$(MAKE) -C $(RPCLIB_DIR)

tests: libs
	$(MAKE) -C $(TEST_CODE_DIR)

benchs: libs
	$(MAKE) -C test/benchmark

eetests: libs js
	$(MAKE) -C $(EETEST_CODE_DIR)

# Use this to re-link tests with the libraries
rebuildtests: libs
	$(MAKE) -C $(TEST_CODE_DIR) FORCE=y

rebuildee: libs
	$(MAKE) -C $(EETEST_CODE_DIR) FORCE=y

demos: bulletdemo onigdemo

bulletdemo: js
	@echo "Building Bullet demo:"
	@cd demos/BulletRPC && ./setup.sh

onigdemo: js
	@echo "Building Oniguruma demo:"
	@cd demos/OnigRPC && ./setup.sh


# cleaning

cleanlib:
	$(MAKE) -C $(RPCLIB_DIR) clean

cleantest:
	$(MAKE) -C $(TEST_CODE_DIR) clean

cleanee:
	$(MAKE) -C $(EETEST_CODE_DIR) clean


clean: cleantest cleanlib cleanlib cleanee
cleanbuild: clean all

# hard clean cleans ALL TOOLCHAIN builds and also for both Release and Debug.
hardclean:
	$(MAKE) clean TOOLCHAIN=all CONFIG=Release
	$(MAKE) clean TOOLCHAIN=all CONFIG=Debug

# testing
test: nodetest jstest cpptest eetest

nodetest: $(NM_BIN_PATH)
	@echo "\n\n** RUNNING NODE.JS TESTS **\n\n"
	@npm test

cpptest: libs tests $(KARMA_BIN)
	@echo "\n\n** RUNNING C++ TESTS **\n\n"
	@touch $(NACL_EXE_STDOUT)
	@export NACL_EXE_STDOUT="$(NACL_EXE_STDOUT)" ; tail -n 0 -f $(NACL_EXE_STDOUT) & TAILPID=$$! && $(KARMA_START) $(KARMA_CPP_CONF) $(KARMA_RUN_ARGS) ; kill $$TAILPID

bench: libs benchs $(KARMA_BIN)
	@echo "\n\n** RUNNING BENCHMARKS **\n\n"
	@touch $(NACL_EXE_STDOUT)
	@export NACL_EXE_STDOUT="$(NACL_EXE_STDOUT)" ; tail -n 0 -f $(NACL_EXE_STDOUT) & TAILPID=$$! && $(KARMA_START) $(KARMA_BENCH_CONF) $(KARMA_RUN_ARGS) ; kill $$TAILPID


eetest: libs eetests js $(KARMA_BIN)
	@echo "\n\n** RUNNING E2E TESTS **\n\n"
	@touch $(NACL_EXE_STDOUT)
	@export NACL_EXE_STDOUT="$(NACL_EXE_STDOUT)" ; tail -n 0 -f $(NACL_EXE_STDOUT) & TAILPID=$$! && $(KARMA_START) $(KARMA_EE_CONF) $(KARMA_RUN_ARGS) ; kill $$TAILPID



jstest: $(KARMA_BIN)
	@echo "\n\n** RUNNING JAVASCRIPT TESTS **\n\n"
	@$(KARMA_START) $(KARMA_JS_CONF) $(KARMA_RUN_ARGS)

jswatch: $(KARMA_BIN)
	@$(KARMA_START) $(KARMA_JS_CONF) $(KARMA_WATCH_ARGS)

# running
serve: $(NM_BIN_PATH)
	@npm run serve
