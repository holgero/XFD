package de.holger_oehm.usb.leds;

import de.holger_oehm.usb.hid.HiDevice;

abstract class AbstractLeds implements USBLeds {
    private final byte[] reportData = new byte[8];

    private final HiDevice device;

    public AbstractLeds(final HiDevice device) {
        this.device = device;
    }

    @Override
    public void close() {
        off();
        device.close();
    }

    protected final void setReportData(final int b1, final int b2, final int b3) {
        reportData[0] = (byte) b1;
        reportData[1] = (byte) b2;
        reportData[2] = (byte) b3;
        device.setReport(0, reportData);
    }

    protected final void setReportData(final int b1, final int b2, final int b3, final int b4, final int b5) {
        reportData[3] = (byte) b4;
        reportData[4] = (byte) b5;
        setReportData(b1, b2, b3);
    }
}