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

#ifndef USBLEDS_H
#define	USBLEDS_H

#include <stdlib.h>
#include <stdio.h>
#include <usb.h>

#include "LED.hpp"

#define ENDPOINT 0x81
#define ID_VENDOR 0x1d50
#define ID_PRODUCT 0x6039

class USBLeds {
public:
    USBLeds();
    void open();
    bool isConnected();
    void init();
    void switchOff();
    void setLED(LED newLED);
    LED getLED();
    void close();
    virtual ~USBLeds();
private:
    void send(char *data, int size);
    void receive(char *data, int size);
    struct usb_device *device;
    struct usb_dev_handle *handle;
};

#endif	/* USBLEDS_H */
