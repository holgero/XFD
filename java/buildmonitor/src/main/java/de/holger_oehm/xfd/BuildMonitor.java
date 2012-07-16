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
