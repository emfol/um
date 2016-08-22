
ARCH := $(shell uname -m)
OS   := $(shell uname -s)

SRCDIR := src
BINDIR := bin
TEMP   := *.log

AS      := as
AS_ARGS :=

LD      := ld
LD_ARGS :=

AR      := ar
AR_ARGS := crs

ifeq ($(OS),Linux)

  ifdef LISTING
    AS_ARGS := $(AS_ARGS) -al=$(LISTING)
  endif

endif

clean:
	rm -rf $(TEMP) $(BINDIR) > /dev/null 2>&1

.PHONY: clean
