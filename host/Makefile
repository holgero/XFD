CC = g++
CFLAGS = -Wall
LIBS = -lusb
SRC = main.cpp USBLeds.cpp USBLeds.hpp LED.cpp LED.hpp
BIN = usbleds

main: $(SRC)
	$(CC) $(CFLAGS) -o $(BIN) $+ -DVID=0x$(VID) -DPID=0x$(PID) $(LIBS)

install:
	install -v -m755 $(BIN) /usr/bin/$(BIN)

.PHONY: clean
clean:
	rm -f $(BIN)
