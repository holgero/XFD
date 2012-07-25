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
