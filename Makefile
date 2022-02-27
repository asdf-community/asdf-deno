SH_SRCFILES = $(shell git ls-files "bin/*")
BATS_SRCFILES = $(shell git ls-files "test/*")
SHFMT_BASE_FLAGS = -s -i 2 -ci

fmt:
	shfmt -w $(SHFMT_BASE_FLAGS) $(SH_SRCFILES)
	shfmt -w -ln bats $(SHFMT_BASE_FLAGS) $(BATS_SRCFILES)
.PHONY: fmt

fmt-check:
	shfmt -d $(SHFMT_BASE_FLAGS) $(SH_SRCFILES)
	shfmt -d -ln bats $(SHFMT_BASE_FLAGS) $(BATS_SRCFILES)
.PHONY: fmt-check

lint:
	shellcheck $(SH_SRCFILES)
.PHONY: lint

test:
	bats test
.PHONY: test
