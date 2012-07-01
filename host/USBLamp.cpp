#include "USBLamp.hpp"

USBLamp::USBLamp() {
    handler = NULL;
}

void USBLamp::open() {
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
                handler = usb_open(device);
                usb_detach_kernel_driver_np(handler, 0);
                usb_claim_interface(handler, 0);
                return;
            }
        }
    }

    return;
}

void USBLamp::send(char *bytes, int size) {
    int requesttype = USB_TYPE_CLASS | USB_RECIP_INTERFACE;
    int request = 0x09;
    int value = 0x200;
    int index = 0x00;
    int timeout = 100;

    int result = usb_control_msg(handler, requesttype, request, value,
                    index, bytes, size, timeout);
    if (size != result) {
        printf("Error: leds???\n");
    }
}

void USBLamp::init() {
}

void USBLamp::setLED(LED newLED) {
    char data[] = {newLED.red ? 0x02 : 0x00,
		   newLED.yellow ? 0x02 : 0x00,
		   newLED.green ? 0x02 : 0x00,
		   0x00, 0x00, 0x00, 0x00, 0x00};
    send(data, 8);
}

void USBLamp::switchOff() {
    setLED(LED());
}

bool USBLamp::isConnected() {
    return handler != NULL;
}

void USBLamp::close() {
    usb_release_interface(handler, 0);
    usb_close(handler);
}

USBLamp::~USBLamp() {
}
