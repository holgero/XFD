package de.holger_oehm.usb.hid.linux;

import com.sun.jna.Structure;

public class UsbDeviceDescriptor extends Structure {
    public static class ByReference extends UsbDeviceDescriptor implements Structure.ByReference {
    }

    public byte bLength;
    public byte bDescriptorType;
    public short bcdUSB;
    public byte bDeviceClass;
    public byte bDeviceSubClass;
    public byte bDeviceProtocol;
    public byte bMaxPacketSize0;
    public short idVendor;
    public short idProduct;
    public short bcdDevice;
    public byte iManufacturer;
    public byte iProduct;
    public byte iSerialNumber;
    public byte bNumConfigurations;
}
