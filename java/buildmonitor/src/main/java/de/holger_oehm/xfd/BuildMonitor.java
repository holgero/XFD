/*  BuildMonitor main class
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

package de.holger_oehm.xfd;

import java.util.Iterator;

import de.holger_oehm.usb.device.USBDeviceException;
import de.holger_oehm.usb.leds.USBLeds;
import de.holger_oehm.usb.leds.USBLeds.LedColor;
import de.holger_oehm.xfd.jenkins.BuildState;
import de.holger_oehm.xfd.jenkins.JenkinsMonitor;

public class BuildMonitor {
    public static void main(final String[] args) {
        new BuildMonitor(args[0]).run();
    }

    private final JenkinsMonitor monitor;
    private final String url;
    private USBLeds leds;

    public BuildMonitor(final String url) {
        this.url = url;
        monitor = new JenkinsMonitor(url);
    }

    private void run() {
        waitForLedsAvailable();
        registerShutdownHook();
        do {
            try {
                Thread.sleep(1000);
                final BuildState buildState = monitor.state();
                System.out.println(url + ": " + buildState);
                switch (buildState) {
                case OK:
                    leds.green();
                    break;
                case OK_BUILDING:
                    leds.set(LedColor.GREEN, LedColor.YELLOW);
                    break;
                case INSTABLE:
                case INSTABLE_BUILDING:
                    leds.yellow();
                    break;
                case FAILED:
                    leds.red();
                    break;
                case FAILED_BUILDING:
                    leds.set(LedColor.RED, LedColor.YELLOW);
                    break;
                default:
                    throw new IllegalStateException("Unexpected state " + buildState);
                }
                Thread.sleep(60000);
            } catch (final InterruptedException interrupt) {
                Thread.currentThread().interrupt();
                leds.off();
                return;
            } catch (final USBDeviceException e) {
                System.err.println(e.getClass().getSimpleName() + ": " + e.getLocalizedMessage());
                recoverFromUSBException();
            } catch (final Exception e) {
                System.err.println(e.getClass().getSimpleName() + ": " + e.getLocalizedMessage());
                leds.set(LedColor.RED, LedColor.YELLOW, LedColor.GREEN);
            }
        } while (true);
    }

    private void recoverFromUSBException() {
        try {
            leds.close();
        } catch (final USBDeviceException e) {
            System.err.println("Ignoring \"" + e.getClass().getSimpleName() + ": " + e.getLocalizedMessage()
                    + "\" during close while trying to recover from previous error.");
        }
        leds = null;
        waitForLedsAvailable();
    }

    private void waitForLedsAvailable() {
        try {
            do {
                final Iterator<USBLeds> enumerator = USBLeds.Factory.enumerateLedDevices();
                if (enumerator.hasNext()) {
                    leds = enumerator.next();
                }
                if (leds == null) {
                    Thread.sleep(10000);
                }
            } while (leds == null);
        } catch (final InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException(e);
        }
    }

    private void registerShutdownHook() {
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                if (leds != null) {
                    leds.close();
                }
            }
        });
    }
}
