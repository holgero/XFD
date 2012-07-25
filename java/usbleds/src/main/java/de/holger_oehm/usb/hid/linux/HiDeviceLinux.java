/*
 *  Copyright (C) 2012 Holger Oehm
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

package de.holger_oehm.usb.hid.linux;

import com.sun.jna.Pointer;

import de.holger_oehm.usb.hid.HiDevice;
import de.holger_oehm.usb.hid.HiDeviceException;
import de.holger_oehm.usb.hid.USBAddress;

public class HiDeviceLinux implements HiDevice {

    private final USBAddress address;
    private UsbDevice device;
    private Pointer handle;

    public HiDeviceLinux(final USBAddress address) {
        this.address = address;
        open();
    }

    private void open() {
        Usblib.INSTANCE.usb_init();
        Usblib.INSTANCE.usb_find_busses();
        Usblib.INSTANCE.usb_find_devices();

        final UsbBus busses = Usblib.INSTANCE.usb_get_busses();
        for (UsbBus bus = busses; bus != null; bus = bus.next) {
            for (UsbDevice dev = bus.devices; dev != null; dev = dev.next) {
                final USBAddress usbAddress = new USBAddress(dev.descriptor.idVendor, dev.descriptor.idProduct);
                if (usbAddress.equals(address)) {
                    device = dev;
                    handle = Usblib.INSTANCE.usb_open(device);
                    break;
                }
            }
            if (handle != null) {
                break;
            }
        }
        if (handle == null) {
            throw new HiDeviceException.HIDDeviceNotFoundException("no device with address " + address + " found.");
        }
        Usblib.INSTANCE.usb_detach_kernel_driver_np(handle, 0);
        Usblib.INSTANCE.usb_claim_interface(handle, 0);
    }

    @Override
    public void close() {
        final Pointer deviceHandle = handle;
        handle = null;
        Usblib.INSTANCE.usb_release_interface(deviceHandle, 0);
        Usblib.INSTANCE.usb_close(deviceHandle);
    }

    private static final int USB_TYPE_CLASS = (0x01 << 5);
    private static final int USB_RECIP_INTERFACE = 0x01;
    private static final int HID_SET_REPORT = 0x09;

    @Override
    public void setReport(final int reportNumber, final byte[] report) {
        final int requesttype = USB_TYPE_CLASS | USB_RECIP_INTERFACE;
        Usblib.INSTANCE.usb_control_msg(handle, requesttype, HID_SET_REPORT, 0, reportNumber, report, report.length, 100);
    }

}
