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
