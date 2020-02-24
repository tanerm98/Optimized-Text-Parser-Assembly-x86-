CC=gcc
CFLAGS=-m32 -fno-stack-protector -nostartfiles -nostdlib -nodefaultlibs
SPEED_O=tema3_speed.o
SIZE_O=tema3_size.o
SPEED=tema3_speed
SIZE=tema3_size
TARGETS=$(SPEED) $(SIZE)

all: $(TARGETS)

tema3_speed.o:
	nasm -f elf32 tema3.asm -o tema3_speed.o
tema3_size.o:
	nasm -f elf32 tema3.asm -o tema3_size.o

$(SPEED): $(SPEED_O)
$(SIZE): $(SIZE_O)

$(SPEED) $(SIZE):
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f tema3_speed tema3_size *.o
