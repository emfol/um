include ../common/makefile

BINARIES := $(BINARIES) bin/test

ifeq ($(OS),Linux)

  AS_ARGS := -march=i386 $(AS_ARGS)

  ifeq ($(ARCH),x86_64)
    AS_ARGS := --32 $(AS_ARGS)
    LD_ARGS := -m elf_i386 $(LD_ARGS)
  endif

else ifeq ($(OS),Darwin)

  AS_ARGS := -arch i386

endif

bin/test: bin/test.o bin/string.o
	$(LD) $(LD_ARGS) -e main $+ -o $@

bin/test.o: src/test.s
	$(AS) $(AS_ARGS) $< -o $@

bin/string.o: src/lib/string.s
	$(AS) $(AS_ARGS) $< -o $@
