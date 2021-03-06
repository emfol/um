include ../common/makefile

LD_ARGS := -static $(LD_ARGS)

ifeq ($(OS),Linux)

  LIBSYS_API := linux
  AS_ARGS := -march=i586 $(AS_ARGS)

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

$(LIBSYS_OBJ): $(BINDIR)/%.o : $(SRCDIR)/%.s
	mkdir -p $(dir $@)
	$(AS) $(AS_ARGS) -o $@ $<
$(LIBSYS_ARCHIVE): $(LIBSYS_OBJ)
	$(AR) $(AR_ARGS) $@ $?
$(LIBSYS_NAME): $(LIBSYS_ARCHIVE)

# libum

LIBUM_NAME    := libum
LIBUM_ARCHIVE := $(BINDIR)/$(LIBUM_NAME).a
LIBUM_SRC     := $(wildcard $(SRCDIR)/lib/um/*.s)
LIBUM_OBJ     := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(LIBUM_SRC))

$(LIBUM_OBJ): $(BINDIR)/%.o : $(SRCDIR)/%.s
	mkdir -p $(dir $@)
	$(AS) $(AS_ARGS) -o $@ $<
$(LIBUM_ARCHIVE): $(LIBUM_OBJ)
	$(AR) $(AR_ARGS) $@ $?
$(LIBUM_NAME): $(LIBUM_ARCHIVE)

# tests

TEST_LOG := tests.log
TEST_SRC := $(wildcard $(SRCDIR)/test/*.s)
TEST_OBJ := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(TEST_SRC))
TEST_BIN := $(patsubst %.o,%,$(TEST_OBJ))
TEST_CMD := $(subst $(BINDIR)/test/,test_,$(TEST_BIN))

$(TEST_OBJ): $(BINDIR)/%.o: $(SRCDIR)/%.s
	mkdir -p $(dir $@)
	$(AS) $(AS_ARGS) -o $@ $<
$(TEST_BIN): %: %.o $(LIBUM_ARCHIVE) $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@
$(TEST_CMD): test_%: $(BINDIR)/test/%
	$< >> $(TEST_LOG) 2>&1; echo "Result: $$?"

# tests v2

TEST2_LOG := test2.log
TEST2_RTS := $(SRCDIR)/test/v2/runtime/main.s
TEST2_RTO := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(TEST2_RTS))
TEST2_SRC := $(wildcard $(SRCDIR)/test/v2/*.s)
TEST2_OBJ := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(TEST2_SRC))
TEST2_BIN := $(patsubst %.o,%,$(TEST2_OBJ))
TEST2_CMD := $(subst $(BINDIR)/test/v2/,test2_,$(TEST2_BIN))

$(TEST2_RTO): $(TEST2_RTS)
	mkdir -p $(dir $@)
	$(AS) $(AS_ARGS) -o $@ $<
$(TEST2_OBJ): $(BINDIR)/%.o: $(SRCDIR)/%.s
	mkdir -p $(dir $@)
	$(AS) $(AS_ARGS) -o $@ $<
$(TEST2_BIN): %: $(TEST2_RTO) %.o $(LIBUM_ARCHIVE) $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@
$(TEST2_CMD): test2_%: $(BINDIR)/test/v2/%
	$< > $(TEST2_LOG) 2>&1; echo "Result: $$?"

# apps

APP_SRC  := $(wildcard $(SRCDIR)/app/*.s)
APP_OBJ  := $(patsubst $(SRCDIR)/%.s,$(BINDIR)/%.o,$(APP_SRC))
APP_BIN  := $(patsubst %.o,%,$(APP_OBJ))
APP_CMD  := $(subst $(BINDIR)/app/,,$(APP_BIN))

$(APP_OBJ): $(BINDIR)/%.o : $(SRCDIR)/%.s
	mkdir -p $(dir $@)
	$(AS) $(AS_ARGS) -o $@ $<
$(APP_BIN): % : %.o $(LIBUM_ARCHIVE) $(LIBSYS_ARCHIVE)
	$(LD) $(LD_ARGS) -e start $+ -o $@
$(APP_CMD): % : $(BINDIR)/app/%

# Static Pattern Rules Example
# oops.2 goops.2 doops.2: %.2: %.1
# 	echo 'Making: $@ ( $+ )'
# oops.1 goops.1 doops.1:
# 	echo 'Making: $@'

.PHONY: $(LIBSYS_NAME) $(LIBUM_NAME)
