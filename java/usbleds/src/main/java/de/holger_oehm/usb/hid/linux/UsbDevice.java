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
