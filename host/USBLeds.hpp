#ifndef USBLEDS_H
#define	USBLEDS_H

#include <stdlib.h>
#include <stdio.h>
#include <usb.h>

#include "LED.hpp"

#define ENDPOINT 0x81
#define ID_VENDOR 0x04d8
#define ID_PRODUCT 0xff0c

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
