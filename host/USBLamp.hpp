#ifndef USBLAMP_H
#define	USBLAMP_H

#include <stdlib.h>
#include <stdio.h>
#include <usb.h>

#include "LED.hpp"

#define ENDPOINT 0x81
#define ID_VENDOR 0x04d8
#define ID_PRODUCT 0xff0c

class USBLamp {
public:
    USBLamp();
    void open();
    bool isConnected();
    void init();
    void switchOff();
    void setLED(LED newLED);
    void close();
    virtual ~USBLamp();
private:
    void send(char *data, int size);
    struct usb_device *device;
    struct usb_dev_handle *handler;
};

#endif	/* USBLAMP_H */
