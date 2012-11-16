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

package de.holger_oehm.usb;

import java.io.IOException;
import java.util.Iterator;

import de.holger_oehm.usb.leds.USBLeds;

public class TestUSBLeds {
    private static final long BLINKTIME = 500L;

    public static void main(final String[] args) throws InterruptedException, IOException {
        for (final Iterator<USBLeds> iterator = USBLeds.Factory.enumerateLedDevices(); iterator.hasNext();) {
            try (final USBLeds leds = iterator.next()) {
                for (int i = 0; i < 3; i++) {
                    leds.red();
                    Thread.sleep(BLINKTIME);
                    leds.yellow();
                    Thread.sleep(BLINKTIME);
                    leds.green();
                    Thread.sleep(BLINKTIME);
                    leds.blue();
                    Thread.sleep(BLINKTIME);
                    leds.white();
                    Thread.sleep(BLINKTIME);
                    leds.magenta();
                    Thread.sleep(BLINKTIME);
                    leds.cyan();
                    Thread.sleep(BLINKTIME);
                    leds.off();
                    Thread.sleep(2 * BLINKTIME);
                }
            }
        }
    }
}
