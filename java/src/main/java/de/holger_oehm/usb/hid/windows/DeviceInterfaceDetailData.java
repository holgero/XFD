package de.holger_oehm.usb.hid.windows;

import com.sun.jna.Native;
import com.sun.jna.Structure;

/**
 * SP_DEVICE_INTERFACE_DETAIL_DATA structure.
 */
public class DeviceInterfaceDetailData extends Structure {
    /**
     * According to the documentation this should be the size in bytes,
     * including the C terminator of the devicePath. But in practice you have to
     * set this field to 5 on windows 32 bit platforms and to 8 on windows 64
     * bit platforms.
     */
    public int cbSize;
    /**
     * Device interface path, used by the Win32 CreateFile functions.
     */
    public char[] devicePath;

    public DeviceInterfaceDetailData(final int pathLength) {
        if (Native.POINTER_SIZE == 8) {
            // win64 has a different idea of the correct value of cbSize
            cbSize = 8;
        } else {
            // the value on windows 32 bit is 5
            cbSize = getNativeSize(int.class, this) + getNativeSize(char.class, this);
        }
        devicePath = new char[pathLength];
    }
}
