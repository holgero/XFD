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

#include "USBLamp.hpp"
#include "LED.hpp"

LED getLED(char* led) {
	if(strcmp(led, "red") == 0) {
		return LED(true, false, false);
	} else if(strcmp(led, "green") == 0) {
		return LED(false, false, true);
	} else if(strcmp(led, "yellow") == 0) {
		return LED(false, true, false);
	} else {
		return LED();
	}
}

void print_help() {
	std::cout << "Usage: usbleds color" << std::endl;
	std::cout << "   valid colors: [red yellow green off]" << std::endl;
}

int main(int argc, char** argv) {
	if(argc != 2 || !strcmp(argv[1], "-h") || !strcmp(argv[1], "--help")) {
        print_help();
        return 0;
    }

	USBLamp lamp = USBLamp();
	lamp.open();
	if (lamp.isConnected()) {
		lamp.init();
		lamp.setLED(LED());
		LED led = getLED(argv[1]);
		std::cout << ( led.red ? "red" : "" ) << ( led.yellow ? "yellow" : "" )<< ( led.green ? "green" : "" ) << std::endl;
		lamp.setLED(led);
		lamp.close();
	} else {
		std::cout << "no lamp found" << std::endl;
	}

	return 0;
}
