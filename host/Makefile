CC = g++
CFLAGS = -Wall
LIBS = -lusb
SRC = main.cpp USBLamp.cpp USBLamp.hpp LED.cpp LED.hpp
BIN = usblamp

main: $(SRC)
	$(CC) $(CFLAGS) -o $(BIN) $+ $(LIBS)

install:
	install -v -m755 $(BIN) /usr/bin/$(BIN)

.PHONY: clean
clean:
	rm -f $(BIN)
