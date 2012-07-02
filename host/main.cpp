#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <usb.h>
#include <string.h>
#include <iostream>
#include <string>
#include <unistd.h>

#include "USBLeds.hpp"
#include "LED.hpp"

LED getLED(char* led) {
	bool red = (index(led, 'r') != NULL);
	bool yellow = (index(led, 'y') != NULL);
	bool green = (index(led, 'g') != NULL);
	bool blue = (index(led, 'b') != NULL);
	bool white = (index(led, 'w') != NULL);
	return LED(red, yellow, green, blue, white);
}

void print_help() {
	std::cout << "Usage: usbleds [r][y][g]" << std::endl;
}

void dump(LED led) {
    std::cout << ( led.red ? "red " : "" )
	<< ( led.yellow ? "yellow " : "" )
	<< ( led.green ? "green " : "" )
	<< ( led.blue ? "blue " : "" )
	<< ( led.white ? "white " : "" )
	<< std::endl;
}

int main(int argc, char** argv) {
    if (argc > 1) {
        if (argc > 2 || !strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) {
            print_help();
            return 0;
	}
    }

	USBLeds leds = USBLeds();
	leds.open();
	if (leds.isConnected()) {
		leds.init();
		if (argc == 2) {
			LED led = getLED(argv[1]);
			dump(led);
			leds.setLED(led);
			leds.close();
		} else {
			LED led = leds.getLED();
			dump(led);
		}
	} else {
		std::cout << "no leds found" << std::endl;
	}

	return 0;
}
