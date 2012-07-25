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

package de.holger_oehm.usb.hid.windows;

import com.sun.jna.Structure;

/**
 * The HIDD_ATTRIBUTES structure contains vendor information about a HIDClass
 * device.
 */
public class HidAttributes extends Structure {
	/**
	 * Specifies the size, in bytes, of a HIDD_ATTRIBUTES structure.
	 */
	public int size = size();
	/**
	 * Specifies a HID device's vendor ID.
	 */
	public short vendorID;
	/**
	 * Specifies a HID device's product ID.
	 */
	public short productID;
	/**
	 * Specifies the manufacturer's revision number for a HIDClass device.
	 */
	public short versionNumber;
}
