package de.holger_oehm.usb.leds;

import de.holger_oehm.usb.hid.HiDevice;

final class DyiLeds extends AbstractLeds implements USBLeds {

    public DyiLeds(final HiDevice device) {
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
