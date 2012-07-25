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

import de.holger_oehm.usb.leds.USBLeds;
import de.holger_oehm.xfd.jenkins.BuildState;
import de.holger_oehm.xfd.jenkins.JenkinsMonitor;

public class BuildMonitor {
    private static final USBLeds LEDS = USBLeds.Factory.enumerateLedDevices().next();

    public static void main(final String[] args) {
        Runtime.getRuntime().addShutdownHook(new Thread() {
            @Override
            public void run() {
                LEDS.close();
            }
        });
        new BuildMonitor(args[0]).run();
    }

    private final JenkinsMonitor monitor;
    private final String url;

    public BuildMonitor(final String url) {
        this.url = url;
        monitor = new JenkinsMonitor(url);
    }

    private void run() {
        do {
            try {
                Thread.sleep(1000);
                final BuildState buildState = monitor.state();
                System.out.println(url + ": " + buildState);
                switch (buildState) {
                case OK:
                    LEDS.green();
                    break;
                case BUILDING:
                case INSTABLE:
                    LEDS.yellow();
                    break;
                case FAILED:
                    LEDS.red();
                    break;
                default:
                    throw new IllegalStateException("Unexpected state " + buildState);
                }
                Thread.sleep(60000);
            } catch (final InterruptedException interrupt) {
                Thread.currentThread().interrupt();
                LEDS.off();
                return;
            } catch (final Exception e) {
                System.err.println(e.getClass().getSimpleName() + ": " + e.getLocalizedMessage());
                LEDS.magenta();
            }
        } while (true);
    }
}
