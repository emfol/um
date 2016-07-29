
ARCH := $(shell uname -m)
OS   := $(shell uname -s)

SRCDIR   := src
BINDIR   := bin
BINARIES := $(BINDIR)/*.o $(BINDIR)/*.a $(BINDIR)/*.so
GARBAGE  := *.log

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
	rm -f $(GARBAGE) $(BINARIES) > /dev/null 2>&1

.PHONY: clean
