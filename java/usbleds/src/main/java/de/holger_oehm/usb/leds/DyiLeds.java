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

public final class DyiLeds extends AbstractLeds implements USBLeds {

    public DyiLeds(final SimpleUSBDevice device) {
        super(device);
    }

    @Override
    public void red() {
        setReportData(1, 0, 0, 0, 0);
    }

    @Override
    public void off() {
        setReportData(0, 0, 0, 0, 0);
    }

    @Override
    public void yellow() {
        setReportData(0, 1, 0, 0, 0);
    }

    @Override
    public void green() {
        setReportData(0, 0, 1, 0, 0);
    }

    @Override
    public void blue() {
        setReportData(0, 0, 0, 1, 0);
    }

    @Override
    public void white() {
        setReportData(0, 0, 0, 0, 1);
    }

    @Override
    public void magenta() {
        setReportData(1, 0, 0, 1, 0);
    }

    @Override
    public void cyan() {
        setReportData(0, 1, 0, 1, 0);
    }

    public void flash() {
        setReportData(0, 0, 0, 0, 0, 0, 0, 0x042);
    }

    @Override
    public void set(final LedColor... colors) {
        int red = 0, yellow = 0, green = 0, blue = 0, white = 0;
        for (final LedColor ledColor : colors) {
            switch (ledColor) {
            case RED:
                red = 1;
                break;
            case YELLOW:
                yellow = 1;
                break;
            case GREEN:
                green = 1;
                break;
            case BLUE:
                blue = 1;
                break;
            case WHITE:
                white = 1;
                break;
            case CYAN:
                green = 1;
                blue = 1;
                break;
            case MAGENTA:
                blue = 1;
                red = 1;
                break;
            default:
                throw new IllegalStateException("Unexpected color " + ledColor);
            }
        }
        setReportData(red, yellow, green, blue, white);
    }
}
