package de.holger_oehm.usb.hid;

import java.io.Closeable;

public interface HiDevice extends Closeable {

    /**
     * Closes this HiDevice and releases any system resources associated with
     * it.
     */
    @Override
    public void close();

    /**
     * Sends an output report to this hi device.
     * 
     * @param reportNumber
     *            the number of the report (usually 0).
     * @param report
     *            the contents of the report
     */
    void setReport(final int reportNumber, final byte[] report);
}