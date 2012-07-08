package de.holger_oehm.usb.hid;

import de.holger_oehm.usb.hid.linux.HiDeviceLinux;
import de.holger_oehm.usb.hid.windows.HiDeviceWin;

public class HiDeviceFactory {

    public HiDevice create(final USBAddress address) {
        if ("linux".equalsIgnoreCase(System.getProperty("os.name"))) {
            return new HiDeviceLinux(address);
        }
        return new HiDeviceWin(address);
    }
}
