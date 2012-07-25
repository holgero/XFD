/*
    eXtreme Feedback Device
    USB connected device which switches some LEDs on and off
    Copyright (C) 2012 Holger Oehm

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

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
