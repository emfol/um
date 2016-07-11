
ARCH := $(shell uname -m)
OS   := $(shell uname -s)

BINARIES := bin/*.o bin/*.a bin/*.so

AS      := as
AS_ARGS :=

LD      := ld
LD_ARGS :=

ifeq ($(OS),Linux)

  ifdef LISTING
    AS_ARGS := $(AS_ARGS) -al=$(LISTING)
  endif

endif

.PHONY: clean

clean:
	rm -f $(BINARIES) > /dev/null 2>&1

