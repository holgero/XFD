package de.holger_oehm.usb.hid.windows;

import com.sun.jna.Structure;

/**
 * Java representation of the SP_DEVICE_INTERFACE_DETAIL_DATA structure. It
 * contains the path for a device interface.
 */
public class DeviceInterfaceDetailData extends Structure {
	/**
	 * The size, in bytes, of the fixed portion of the
	 * SP_DEVICE_INTERFACE_DETAIL_DATA structure.
	 */
	public int cbSize;
	/**
	 * A NULL-terminated string that contains the device interface path. This
	 * path can be passed to Win32 functions CreateFile.
	 */
	public char[] devicePath;

	public DeviceInterfaceDetailData(final int pathLength) {
		setAlignType(Structure.ALIGN_NONE);
		cbSize = getNativeSize(int.class, this) + getNativeSize(char.class, this);
		devicePath = new char[pathLength];
	}
}
