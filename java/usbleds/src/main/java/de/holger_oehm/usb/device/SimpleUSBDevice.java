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

package de.holger_oehm.usb.device;

import java.io.Closeable;

/**
 * A simple usb device that accepts reports.
 */
public interface SimpleUSBDevice extends Closeable {

    /**
     * Closes this SimpleUSBDevice and releases any system resources associated
     * with it.
     */
    @Override
    public void close();

    /**
     * Sends an output report to this device.
     * 
     * @param reportNumber
     *            the number of the report (usually 0).
     * @param report
     *            the contents of the report
     */
    void setReport(final short reportNumber, final byte[] report);
}
