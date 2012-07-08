package de.holger_oehm.usb.leds;

import de.holger_oehm.usb.hid.HiDevice;

final class DreamCheekyLeds extends AbstractLeds implements USBLeds {

    public DreamCheekyLeds(final HiDevice device) {
        super(device);
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
}
