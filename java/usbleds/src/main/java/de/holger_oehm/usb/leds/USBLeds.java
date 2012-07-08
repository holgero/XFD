package de.holger_oehm.usb.leds;

import java.io.Closeable;
import java.util.Iterator;

import de.holger_oehm.usb.hid.HiDevice;
import de.holger_oehm.usb.hid.HiDeviceException.HIDDeviceNotFoundException;
import de.holger_oehm.usb.hid.HiDeviceFactory;
import de.holger_oehm.usb.hid.USBAddress;

public interface USBLeds extends Closeable {
    public static final class Factory {

        private static final USBAddress USBLEDS = new USBAddress(0x04d8, 0xff0c);
        private static final USBAddress DREAM_CHEEKY = new USBAddress(0x1d34, 0x0004);

        private static final class LedDevicesIterator implements Iterator<USBLeds> {
            boolean triedUsbLeds = false;
            boolean triedDreamCheeky = false;
            USBLeds next = null;

            @Override
            public boolean hasNext() {
                if (next != null) {
                    return true;
                }
                if (!triedUsbLeds) {
                    triedUsbLeds = true;
                    tryCreateNext(USBLEDS);
                }
                if (next != null) {
                    return true;
                }
                if (!triedDreamCheeky) {
                    triedDreamCheeky = true;
                    tryCreateNext(DREAM_CHEEKY);
                }
                if (next != null) {
                    return true;
                }
                return false;
            }

            private void tryCreateNext(final USBAddress address) {
                try {
                    next = createInstance(address);
                } catch (final HIDDeviceNotFoundException e) {
                }
            }

            @Override
            public USBLeds next() {
                if (!hasNext()) {
                    return null;
                }
                final USBLeds result = next;
                next = null;
                return result;
            }

            @Override
            public void remove() {
            }
        }

        public static Iterator<USBLeds> enumerateLedDevices() {
            return new LedDevicesIterator();
        }

        public static USBLeds createInstance(final USBAddress address) {
            final HiDevice device = new HiDeviceFactory().create(address);
            if (address.getVendorId() == DREAM_CHEEKY.getVendorId()) {
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
