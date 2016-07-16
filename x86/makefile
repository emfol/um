include ../common/makefile

BINARIES := $(BINARIES) bin/test

LD_ARGS := -static $(LD_ARGS)

LIBOS_S :=
LIBOS_O := bin/os.o

ifeq ($(OS),Linux)

  LIBOS_S := src/lib/os/linux.s
  AS_ARGS := -march=i386 $(AS_ARGS)

  ifeq ($(ARCH),x86_64)
    AS_ARGS := --32 $(AS_ARGS)
    LD_ARGS := -m elf_i386 $(LD_ARGS)
  endif

else ifeq ($(OS),Darwin)

  LIBOS_S := src/lib/os/unix.s
  AS_ARGS := -arch i386

endif

bin/test: bin/test.o bin/string.o $(LIBOS_O)
	$(LD) $(LD_ARGS) -e main $+ -o $@

bin/test.o: src/test.s
	$(AS) $(AS_ARGS) -o $@ $<

bin/string.o: src/lib/string.s
	$(AS) $(AS_ARGS) -o $@ $<

$(LIBOS_O): $(LIBOS_S)
	$(AS) $(AS_ARGS) -o $@ $<
