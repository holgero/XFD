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
	return LED(red, yellow, green);
}

void print_help() {
	std::cout << "Usage: usbleds [r][y][g]" << std::endl;
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
		leds.setLED(LED());
		if (argc == 2) {
			LED led = getLED(argv[1]);
			std::cout << ( led.red ? "red" : "" ) << ( led.yellow ? "yellow" : "" )<< ( led.green ? "green" : "" ) << std::endl;
			leds.setLED(led);
			leds.close();
		}
	} else {
		std::cout << "no leds found" << std::endl;
	}

	return 0;
}
