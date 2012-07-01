OBJECTS=usb.o wait.o main.o

%.o : %.asm
	gpasm -c -p p18f2550 -r dec -w 2 $<

all: $(OBJECTS)
	gplink -o XFD.hex -a inhx32 -m $(OBJECTS)
