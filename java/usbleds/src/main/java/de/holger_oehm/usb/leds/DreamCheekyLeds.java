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

import de.holger_oehm.usb.device.SimpleUSBDevice;

final class DreamCheekyLeds extends AbstractLeds implements USBLeds {

    private static final byte[][] INIT_DATA = new byte[][] { { 0x1f, 0x02, 0x00, 0x2e, 0x00, 0x00, 0x2b, 0x03 }, //
            { 0x00, 0x02, 0x00, 0x2e, 0x00, 0x00, 0x2b, 0x04 }, //
            { 0x00, 0x02, 0x00, 0x2e, 0x00, 0x00, 0x2b, 0x05 }, };

    public DreamCheekyLeds(final SimpleUSBDevice device) {
        super(device);
        for (final byte[] element : INIT_DATA) {
            setReportData(element);
        }
        setReportData(0, 0, 0, 0, 0, 0, 0, 5);
    }

    @Override
    public void red() {
        setReportData(64, 0, 0);
    }

    @Override
    public void off() {
        setReportData(0, 0, 0);
    }

    @Override
    public void yellow() {
        setReportData(64, 64, 0);
    }

    @Override
    public void green() {
        setReportData(0, 64, 0);
    }

    @Override
    public void blue() {
        setReportData(0, 0, 64);
    }

    @Override
    public void white() {
        setReportData(64, 64, 64);
    }

    @Override
    public void magenta() {
        setReportData(64, 0, 64);
    }

    @Override
    public void cyan() {
        setReportData(0, 64, 64);
    }

    @Override
    public void set(final LedColor... colors) {
        int red = 0, green = 0, blue = 0;
        for (final LedColor ledColor : colors) {
            switch (ledColor) {
            case RED:
                red = 64;
                break;
            case YELLOW:
                red = 64;
                green = 64;
                break;
            case GREEN:
                green = 64;
                break;
            case BLUE:
                blue = 64;
                break;
            case WHITE:
                red = 64;
                green = 64;
                blue = 64;
                break;
            case CYAN:
                green = 64;
                blue = 64;
                break;
            case MAGENTA:
                red = 64;
                blue = 64;
                break;
            default:
                throw new IllegalStateException("Unexpected color " + ledColor);
            }
        }
        setReportData(red, green, blue);
    }
}
