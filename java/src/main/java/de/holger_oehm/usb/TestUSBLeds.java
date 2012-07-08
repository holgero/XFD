package de.holger_oehm.usb;

import java.io.IOException;

import de.holger_oehm.usb.hid.HiDeviceException.HIDDeviceNotFoundException;
import de.holger_oehm.usb.hid.USBAddress;
import de.holger_oehm.usb.leds.USBLeds;

public class TestUSBLeds {
    private static final USBAddress USBLEDS = new USBAddress(0x04d8, 0xff0c);
    private static final USBAddress DREAM_CHEEKY = new USBAddress(0x1d34, 0x0004);

    public static void main(final String[] args) throws InterruptedException, IOException {
        for (final USBAddress address : new USBAddress[] { DREAM_CHEEKY, USBLEDS }) {
            try (final USBLeds leds = USBLeds.Factory.createInstance(address)) {
                for (int i = 0; i < 3; i++) {
                    leds.red();
                    Thread.sleep(100L);
                    leds.yellow();
                    Thread.sleep(100L);
                    leds.green();
                    Thread.sleep(100L);
                    leds.blue();
                    Thread.sleep(100L);
                    leds.white();
                    Thread.sleep(100L);
                    leds.magenta();
                    Thread.sleep(100L);
                    leds.cyan();
                    Thread.sleep(100L);
                    leds.off();
                    Thread.sleep(200L);
                }
            } catch (final HIDDeviceNotFoundException e) {
                System.err.println("No device found at " + address);
            }
        }
    }
}
