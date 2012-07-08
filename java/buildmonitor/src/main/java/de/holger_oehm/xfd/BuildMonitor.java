package de.holger_oehm.xfd;

import de.holger_oehm.usb.hid.USBAddress;
import de.holger_oehm.usb.leds.USBLeds;
import de.holger_oehm.xfd.jenkins.BuildState;
import de.holger_oehm.xfd.jenkins.JenkinsMonitor;

public class BuildMonitor {

    private static final USBAddress DREAM_CHEEKY = new USBAddress(0x1d34, 0x0004);
    private static final USBAddress USBLEDS = new USBAddress(0x04d8, 0xff0c);

    public static void main(final String[] args) {
        new BuildMonitor(args[0]).run();
    }

    private final JenkinsMonitor monitor;
    private final USBLeds leds;
    private final String url;

    public BuildMonitor(final String url) {
        this.url = url;
        monitor = new JenkinsMonitor(url);
        leds = USBLeds.Factory.createInstance(USBLEDS);
    }

    private void run() {
        do {
            try {
                Thread.sleep(1000);
                final BuildState buildState = monitor.state();
                System.out.println(url + ": " + buildState);
                switch (buildState) {
                case OK:
                    leds.green();
                    break;
                case BUILDING:
                    leds.blue();
                    break;
                case INSTABLE:
                    leds.yellow();
                    break;
                case FAILED:
                    leds.red();
                    break;
                default:
                    throw new IllegalStateException("Unexpected state " + buildState);
                }
                Thread.sleep(60000);
            } catch (final InterruptedException interrupt) {
                Thread.currentThread().interrupt();
                return;
            } catch (final Exception e) {
                System.err.println(e.getClass().getSimpleName() + ": " + e.getLocalizedMessage());
            }
        } while (true);
    }
}
