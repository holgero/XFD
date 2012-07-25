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

package de.holger_oehm.usb.hid;

import de.holger_oehm.usb.hid.linux.HiDeviceLinux;
import de.holger_oehm.usb.hid.windows.HiDeviceWin;

public class HiDeviceFactory {

    public HiDevice create(final USBAddress address) {
        if ("linux".equalsIgnoreCase(System.getProperty("os.name"))) {
            return new HiDeviceLinux(address);
        }
        return new HiDeviceWin(address);
    }
}
