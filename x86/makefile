include ../common/makefile

BINARIES := $(BINARIES) $(BINDIR)/test

LIBDIR := $(SRCDIR)/lib
SYSDIR := $(LIBDIR)/sys

LD_ARGS := -static $(LD_ARGS)

ifeq ($(OS),Linux)

  LIBSYS_API := linux
  AS_ARGS := -march=i386 $(AS_ARGS)

  ifeq ($(ARCH),x86_64)
    AS_ARGS := --32 $(AS_ARGS)
    LD_ARGS := -m elf_i386 $(LD_ARGS)
  endif

else ifeq ($(OS),Darwin)

  LIBSYS_API := unix
  AS_ARGS := -arch i386

endif

AS_ARGS := $(strip $(AS_ARGS))
LD_ARGS := $(strip $(LD_ARGS))
AR_ARGS := $(strip $(AR_ARGS))

LIBSYS_NAME    := libsys
LIBSYS_ARCHIVE := $(BINDIR)/$(LIBSYS_NAME).a
LIBSYS_SRC     := $(SYSDIR)/crt.s $(SYSDIR)/$(LIBSYS_API).s
LIBSYS_OBJ     := $(addprefix $(BINDIR)/sys_, $(notdir $(LIBSYS_SRC:.s=.o)))

$(LIBSYS_NAME): $(LIBSYS_ARCHIVE)
$(LIBSYS_ARCHIVE): $(LIBSYS_OBJ)
	$(AR) $(AR_ARGS) $@ $?
$(LIBSYS_OBJ): $(LIBSYS_SRC)
	$(AS) $(AS_ARGS) -o $(word 1, $(LIBSYS_OBJ)) $(word 1, $(LIBSYS_SRC))
	$(AS) $(AS_ARGS) -o $(word 2, $(LIBSYS_OBJ)) $(word 2, $(LIBSYS_SRC))

test: $(BINDIR)/test
	$< 'abcd efgh'; test $$? -eq 9 && echo 'OK!' || echo 'Oops!'

$(BINDIR)/test: $(BINDIR)/test.o $(BINDIR)/string.o $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@

$(BINDIR)/test.o: $(SRCDIR)/test.s
	$(AS) $(AS_ARGS) -o $@ $<

$(BINDIR)/string.o: $(LIBDIR)/string.s
	$(AS) $(AS_ARGS) -o $@ $<

.PHONY: $(LIBSYS_NAME) test
