#include "USBLeds.hpp"
#include <iostream>
#include <errno.h>
#include <string.h>

USBLeds::USBLeds() {
    handle = NULL;
}

void USBLeds::open() {
    struct usb_bus *busses;

    usb_init();
    usb_find_busses();
    usb_find_devices();

    busses = usb_get_busses();

    struct usb_bus *bus;

    for (bus = busses; bus; bus = bus->next) {
        struct usb_device *dev;

        for (dev = bus->devices; dev; dev = dev->next) {
            if (   ID_VENDOR  == dev->descriptor.idVendor
                && ID_PRODUCT == dev->descriptor.idProduct) {
                device = dev;
                handle = usb_open(device);
                usb_detach_kernel_driver_np(handle, 0);
                usb_claim_interface(handle, 0);
                return;
            }
        }
    }

    return;
}

#define HID_SET_REPORT	0x09
#define HID_GET_REPORT	0x01

void USBLeds::send(char *bytes, int size) {
    int requesttype = USB_TYPE_CLASS | USB_RECIP_INTERFACE;
    int request = HID_SET_REPORT;
    int value = 0x00;
    int index = 0x00;
    int timeout = 100;

    int result = usb_control_msg(handle, requesttype, request, value,
                    index, bytes, size, timeout);
    if (size != result) {
	std::cerr << "send error: " << strerror(errno) << std::endl;
    }
}

void USBLeds::receive(char *bytes, int size) {
    int requesttype = USB_ENDPOINT_IN | USB_TYPE_CLASS | USB_RECIP_INTERFACE;
    int request = HID_GET_REPORT;
    int value = 0x00;
    int index = 0x00;
    int timeout = 1000;

    int result = usb_control_msg(handle, requesttype, request, value,
                    index, bytes, size, timeout);
    if (size != result) {
        std::cerr << "receive error (" << result << "): " << strerror(errno) << std::endl;
    }
}

void USBLeds::init() {
}

void USBLeds::setLED(LED newLED) {
    char data[] = {newLED.red ? 0x01 : 0x00,
		   newLED.yellow ? 0x01 : 0x00,
		   newLED.green ? 0x01 : 0x00,
		   newLED.blue ? 0x01 : 0x00,
		   newLED.white ? 0x01 : 0x00 };
    send(data, sizeof(data));
}

LED USBLeds::getLED() {
    char buffer[5];
    receive(buffer, sizeof(buffer));
    bool red = buffer[0] == 1;
    bool yellow = buffer[1] == 1;
    bool green = buffer[2] == 1;
    bool blue = buffer[3] == 1;
    bool white = buffer[4] == 1;
    return LED(red, yellow, green, blue, white);
}

void USBLeds::switchOff() {
    setLED(LED());
}

bool USBLeds::isConnected() {
    return handle != NULL;
}

void USBLeds::close() {
    usb_release_interface(handle, 0);
    usb_close(handle);
}

USBLeds::~USBLeds() {
}
