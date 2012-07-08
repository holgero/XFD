package de.holger_oehm.usb.leds;

import java.io.Closeable;

import de.holger_oehm.usb.hid.HiDevice;
import de.holger_oehm.usb.hid.HiDeviceFactory;
import de.holger_oehm.usb.hid.USBAddress;

public interface USBLeds extends Closeable {
    public static final class Factory {
        private static final int DREAM_CHEEKY = 0x1d34;

        public static USBLeds createInstance(final USBAddress address) {
            final HiDevice device = new HiDeviceFactory().create(address);
            if (address.getVendorId() == DREAM_CHEEKY) {
                return new DreamCheekyLeds(device);
            }
            return new DyiLeds(device);
        }
    }

    void red();

    void off();

    void yellow();

    void green();

    void blue();

    void white();

    void magenta();

    void cyan();

    /**
     * Switches the LEDs off, closes this USBLeds device and releases any system
     * resources associated with it.
     */
    @Override
    public void close();
}
