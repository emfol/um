include ../common/makefile

BINARIES := $(BINARIES) $(BINDIR)/actr

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

LIBUM_NAME     := libum
LIBUM_ARCHIVE  := $(BINDIR)/$(LIBUM_NAME).a

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

CPUINFO_NAME := cpuinfo
CPUINFO_SRC  := $(SRCDIR)/$(CPUINFO_NAME).s
CPUINFO_OBJ  := $(addprefix $(BINDIR)/, $(notdir $(CPUINFO_SRC:.s=.o)))

actr: $(BINDIR)/actr
$(BINDIR)/actr: $(BINDIR)/actr.o $(LIBUM_ARCHIVE) $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@

$(BINDIR)/actr.o: $(SRCDIR)/actr.s
	$(AS) $(AS_ARGS) -o $@ $<

$(LIBUM_NAME): $(LIBUM_ARCHIVE)
$(LIBUM_ARCHIVE): $(BINDIR)/string.o $(BINDIR)/io.o
	$(AR) $(AR_ARGS) $@ $?

$(BINDIR)/string.o: $(LIBDIR)/string.s
	$(AS) $(AS_ARGS) -o $@ $<

$(BINDIR)/io.o: $(LIBDIR)/io.s
	$(AS) $(AS_ARGS) -o $@ $<


$(CPUINFO_NAME): $(BINDIR)/$(CPUINFO_NAME)
$(BINDIR)/$(CPUINFO_NAME): $(CPUINFO_OBJ) $(LIBUM_ARCHIVE) $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@
$(CPUINFO_OBJ): $(CPUINFO_SRC)
	$(AS) $(AS_ARGS) -o $@ $<
BINARIES := $(BINARIES) $(BINDIR)/cpuinfo

TEST_LOGS    := tests.log
TEST_SRCDIR  := $(SRCDIR)/test
TEST_BINDIR  := $(BINDIR)/test
TEST_SOURCES := $(wildcard $(TEST_SRCDIR)/*.s)
TEST_OBJECTS := $(patsubst $(TEST_SRCDIR)/%.s,$(TEST_BINDIR)/%.o,$(TEST_SOURCES))
TEST_TARGETS := $(patsubst $(TEST_SRCDIR)/%.s,$(BINDIR)/test_%,$(TEST_SOURCES))
TEST_CASES   := $(patsubst $(TEST_SRCDIR)/%.s,test_%,$(TEST_SOURCES))
BINARIES := $(BINARIES) $(BINDIR)/test/*.o $(BINDIR)/test_*

$(TEST_OBJECTS): $(TEST_BINDIR)/%.o: $(TEST_SRCDIR)/%.s
	$(AS) $(AS_ARGS) -o $@ $<

$(TEST_TARGETS): $(BINDIR)/test_%: $(TEST_BINDIR)/%.o $(LIBUM_ARCHIVE) $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@

$(TEST_CASES): test_%: $(BINDIR)/test_%
	$< >> $(TEST_LOGS) 2>&1; echo "Result: $$?"

.PHONY: $(LIBSYS_NAME) $(LIBUM_NAME) test actr $(CPUINFO_NAME)
