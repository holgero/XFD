package de.holger_oehm.usb.hid.linux;

import com.sun.jna.Pointer;
import com.sun.jna.Structure;
import com.sun.jna.ptr.PointerByReference;

public class UsbDevice extends Structure {
    public static class ByReference extends UsbDevice implements Structure.ByReference {
    }

    public UsbDevice.ByReference next;
    public UsbDevice.ByReference prev;

    public byte[] filename = new byte[Usblib.PATH_MAX + 1];

    public UsbBus.ByReference bus;
    public UsbDeviceDescriptor descriptor;
    public UsbDeviceDescriptor.ByReference config;

    public Pointer dev;

    public byte devnum;
    public byte num_children;
    public PointerByReference children;
}
