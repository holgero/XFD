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

abstract class AbstractLeds implements USBLeds {
    private final byte[] reportData = new byte[8];

    private final SimpleUSBDevice device;

    public AbstractLeds(final SimpleUSBDevice device) {
        this.device = device;
    }

    @Override
    public void close() {
        off();
        device.close();
    }

    protected final void setReportData(final byte[] data) {
        device.setReport((short) 0, data);
    }

    protected final void setReportData(final int b1, final int b2, final int b3) {
        reportData[0] = (byte) b1;
        reportData[1] = (byte) b2;
        reportData[2] = (byte) b3;
        setReportData(reportData);
    }

    protected final void setReportData(final int b1, final int b2, final int b3, final int b4, final int b5) {
        reportData[3] = (byte) b4;
        reportData[4] = (byte) b5;
        setReportData(b1, b2, b3);
    }

    protected final void setReportData(final int b1, final int b2, final int b3, final int b4, final int b5, final int b6,
            final int b7, final int b8) {
        reportData[5] = (byte) b6;
        reportData[6] = (byte) b7;
        reportData[7] = (byte) b8;
        setReportData(b1, b2, b3, b4, b5);
    }
}
