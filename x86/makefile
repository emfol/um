include ../common/makefile

BINARIES := $(BINARIES) $(BINDIR)/actr

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

# libsys

LIBSYS_NAME    := libsys
LIBSYS_ARCHIVE := $(BINDIR)/$(LIBSYS_NAME).a
LIBSYS_SRC     := $(wildcard $(SRCDIR)/lib/sys/*.s) $(wildcard $(SRCDIR)/lib/sys/$(LIBSYS_API)/*.s)
LIBSYS_OBJ     := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(LIBSYS_SRC))
LIBSYS_DIR     := $(BINDIR)/lib/sys/$(LIBSYS_API)
BINARIES       := $(BINARIES) $(BINDIR)/lib/sys/*.o $(BINDIR)/lib/sys/$(LIBSYS_API)/*.o

$(LIBSYS_DIR):
	mkdir -p $@
$(LIBSYS_OBJ): $(BINDIR)/%.o : $(SRCDIR)/%.s $(LIBSYS_DIR)
	$(AS) $(AS_ARGS) -o $@ $<
$(LIBSYS_ARCHIVE): $(LIBSYS_OBJ)
	$(AR) $(AR_ARGS) $@ $?
$(LIBSYS_NAME): $(LIBSYS_ARCHIVE)

# libum

LIBUM_NAME    := libum
LIBUM_ARCHIVE := $(BINDIR)/$(LIBUM_NAME).a
LIBUM_SRC     := $(wildcard $(SRCDIR)/lib/um/*.s)
LIBUM_OBJ     := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(LIBUM_SRC))
LIBUM_DIR     := $(BINDIR)/lib/um
BINARIES      := $(BINARIES) $(BINDIR)/lib/um/*.o

$(LIBUM_DIR):
	mkdir -p $@
$(LIBUM_OBJ): $(BINDIR)/%.o : $(SRCDIR)/%.s $(LIBUM_DIR)
	$(AS) $(AS_ARGS) -o $@ $<
$(LIBUM_ARCHIVE): $(LIBUM_OBJ)
	$(AR) $(AR_ARGS) $@ $?
$(LIBUM_NAME): $(LIBUM_ARCHIVE)

# tests

TEST_LOG := tests.log
TEST_SRC := $(wildcard $(SRCDIR)/test/*.s)
TEST_OBJ := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(TEST_SRC))
TEST_BIN := $(patsubst $(SRCDIR)/test/%.s,$(BINDIR)/test_%,$(TEST_SRC))
TEST_CMD := $(subst $(BINDIR)/,,$(TEST_BIN))
TEST_DIR := $(BINDIR)/test
BINARIES := $(BINARIES) $(BINDIR)/test/*.o $(BINDIR)/test_*

$(TEST_DIR):
	mkdir -p $@
$(TEST_OBJ): $(BINDIR)/%.o: $(SRCDIR)/%.s $(TEST_DIR)
	$(AS) $(AS_ARGS) -o $@ $<
$(TEST_BIN): $(BINDIR)/test_%: $(BINDIR)/test/%.o $(LIBUM_ARCHIVE) $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@
$(TEST_CMD): test_%: $(BINDIR)/test_%
	$< >> $(TEST_LOG) 2>&1; echo "Result: $$?"

# apps

APP_SRC  := $(wildcard $(SRCDIR)/app/*.s)
APP_OBJ  := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(APP_SRC))
APP_BIN  := $(patsubst %.o,%,$(APP_OBJ))
APP_CMD  := $(subst $(BINDIR)/app/,,$(APP_BIN))
APP_DIR  := $(BINDIR)/app
BINARIES := $(BINARIES) $(BINDIR)/app/*

$(APP_DIR):
	mkdir -p $@
$(APP_OBJ): $(BINDIR)/%.o : $(SRCDIR)/%.s $(APP_DIR)
	$(AS) $(AS_ARGS) -o $@ $<
$(APP_BIN): % : %.o $(LIBUM_ARCHIVE) $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@
$(APP_CMD): % : $(BINDIR)/app/%

# Static Pattern Rules Example
# oops.2 goops.2 doops.2: %.2: %.1
# 	echo 'Making: $@ ( $+ )'
# oops.1 goops.1 doops.1:
# 	echo 'Making: $@'

.PHONY: $(LIBSYS_NAME) $(LIBUM_NAME) test actr $(CPUINFO_NAME)
