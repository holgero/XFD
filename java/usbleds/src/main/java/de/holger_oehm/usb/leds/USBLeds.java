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

package de.holger_oehm.usb.leds;

import java.io.Closeable;
import java.util.Iterator;

import de.holger_oehm.usb.device.SimpleUSBDevice;
import de.holger_oehm.usb.device.USBAddress;
import de.holger_oehm.usb.device.USBDevice;
import de.holger_oehm.usb.device.USBDeviceException.USBDeviceNotFoundException;

public interface USBLeds extends Closeable {
    public static final class Factory {
        private static final USBAddress USBLEDS = new USBAddress(0x1d50, 0x6039);
        private static final USBAddress DREAM_CHEEKY = new USBAddress(0x1d34, 0x0004);

        private static final class LedDevicesIterator implements Iterator<USBLeds> {
            boolean triedUsbLeds = false;
            boolean triedDreamCheeky = false;
            USBLeds next = null;

            @Override
            public boolean hasNext() {
                if (next != null) {
                    return true;
                }
                if (!triedUsbLeds) {
                    triedUsbLeds = true;
                    tryCreateNext(USBLEDS);
                }
                if (next != null) {
                    return true;
                }
                if (!triedDreamCheeky) {
                    triedDreamCheeky = true;
                    tryCreateNext(DREAM_CHEEKY);
                }
                if (next != null) {
                    return true;
                }
                return false;
            }

            private void tryCreateNext(final USBAddress address) {
                try {
                    next = createInstance(address);
                } catch (final USBDeviceNotFoundException e) {
                }
            }

            @Override
            public USBLeds next() {
                if (!hasNext()) {
                    return null;
                }
                final USBLeds result = next;
                next = null;
                return result;
            }

            @Override
            public void remove() {
            }
        }

        public static Iterator<USBLeds> enumerateLedDevices() {
            return new LedDevicesIterator();
        }

        public static USBLeds createInstance(final USBAddress address) {
            final SimpleUSBDevice device = new USBDevice(address);
            if (address.getVendorId() == DREAM_CHEEKY.getVendorId()) {
                return new DreamCheekyLeds(device);
            }
            return new DyiLeds(device);
        }
    }

    void red();

    void off();

    void yellow();

    void green();

    void blue();

    void white();

    void magenta();

    void cyan();

    /**
     * Switches the LEDs off, closes this USBLeds device and releases any system
     * resources associated with it.
     */
    @Override
    public void close();
}
