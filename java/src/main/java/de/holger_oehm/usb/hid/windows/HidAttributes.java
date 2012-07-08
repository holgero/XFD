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
