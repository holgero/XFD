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

import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Pointer;

public interface Usblib extends Library {
    static final int PATH_MAX = 4096;

    static Usblib INSTANCE = (Usblib) Native.loadLibrary("usb", Usblib.class);

    void usb_init();

    int usb_find_busses();

    int usb_find_devices();

    UsbBus usb_get_busses();

    Pointer usb_open(UsbDevice dev);

    int usb_close(Pointer dev);

    int usb_detach_kernel_driver_np(Pointer dev, int interf);

    int usb_claim_interface(Pointer dev, int interf);

    int usb_release_interface(Pointer dev, int interf);

    int usb_control_msg(Pointer dev, int requesttype, int request, int value, int index, byte[] bytes, int size, int timeout);

}
