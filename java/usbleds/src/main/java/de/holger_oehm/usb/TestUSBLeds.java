package de.holger_oehm.usb;

import java.io.IOException;
import java.util.Iterator;

import de.holger_oehm.usb.leds.USBLeds;

public class TestUSBLeds {
    public static void main(final String[] args) throws InterruptedException, IOException {
        for (final Iterator<USBLeds> iterator = USBLeds.Factory.enumerateLedDevices(); iterator.hasNext();) {
            try (final USBLeds leds = iterator.next()) {
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
            }
        }
    }
}
