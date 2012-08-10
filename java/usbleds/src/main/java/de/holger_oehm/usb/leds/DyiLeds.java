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

final class DyiLeds extends AbstractLeds implements USBLeds {

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
}
