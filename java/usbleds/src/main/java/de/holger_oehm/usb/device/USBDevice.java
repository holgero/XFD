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

package de.holger_oehm.usb.device;

import com.sun.jna.Pointer;

public class USBDevice implements SimpleUSBDevice {

    private final USBAddress address;
    private Pointer handle;

    public USBDevice(final USBAddress address) {
        this.address = address;
        open();
    }

    private void open() {
        handle = Usblib.INSTANCE.libusb_open_device_with_vid_pid(null, address.getVendorId(), address.getProductId());
        if (handle == null) {
            throw new USBDeviceException.USBDeviceNotFoundException("no device with address " + address + " found.");
        }
        Usblib.INSTANCE.libusb_detach_kernel_driver(handle, 0);
        Usblib.INSTANCE.libusb_claim_interface(handle, 0);
    }

    @Override
    public void close() {
        final Pointer deviceHandle = handle;
        handle = null;
        Usblib.INSTANCE.libusb_release_interface(deviceHandle, 0);
        Usblib.INSTANCE.libusb_close(deviceHandle);
    }

    private static final byte USB_TYPE_CLASS = (0x01 << 5);
    private static final byte USB_RECIP_INTERFACE = 0x01;
    private static final byte HID_SET_REPORT = 0x09;

    @Override
    public void setReport(final short reportNumber, final byte[] report) {
        final byte requesttype = USB_TYPE_CLASS | USB_RECIP_INTERFACE;
        final short wValue = 0;
        Usblib.INSTANCE.libusb_control_transfer(handle, requesttype, HID_SET_REPORT, wValue, reportNumber, report,
                (short) report.length, 100);
    }

}
