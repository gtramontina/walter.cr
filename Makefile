.POSIX:
.DELETE_ON_ERROR:
CPUS ?= $(shell (nproc --all || sysctl -n hw.ncpu) 2>/dev/null || echo 1)
MAKEFLAGS += --jobs $(CPUS)

CRYSTAL_BIN ?= $(shell which crystal)
SHARDS_BIN ?= $(shell which shards)

shard-name := $(shell cat shard.yml | grep name | awk '{print $$2}')
source-files := $(shell find src -type f -name "*.cr")
$(foreach env-var,$(shell $(CRYSTAL_BIN) env),$(eval $(env-var)))

# ---

lib: shard.yml
	@$(SHARDS_BIN) install && touch lib
pre-reqs += lib
trash += lib bin shard.lock

bin/$(shard-name): $(source-files)
	@$(SHARDS_BIN) build $(CRFLAGS)
trash += bin/$(shard-name)

# ---

.DEFAULT_GOAL := install

.PHONY: install
install: $(pre-reqs)

.PHONY: build
build: bin/$(shard-name)

.PHONY: test
test: $(pre-reqs); @CRYSTAL_PATH=$(CRYSTAL_PATH):src $(CRYSTAL_BIN) spec -- -c -p $(CPUS)

.PHONY: lint
lint: $(pre-reqs); @bin/ameba

.PHONY: format
format: $(pre-reqs); @$(CRYSTAL_BIN) tool format

.PHONY: clean
clean:; @-rm -rf $(trash)

.PHONY: help
help:; @MAKEFLAGS= $(MAKE) -rpn | grep -B1 PHONY | egrep "^[^#-._[:space:]]" \
	| cut -d':' -f1 | sed -e 's/^$(.DEFAULT_GOAL)$$/$(.DEFAULT_GOAL) (default)/' \
	| sort -u | sed -e 's/^/make /'
