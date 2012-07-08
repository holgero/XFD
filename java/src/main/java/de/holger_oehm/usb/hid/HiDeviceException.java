package de.holger_oehm.usb.hid;

public class HiDeviceException extends RuntimeException {

	public static final class HIDDeviceNotFoundException extends HiDeviceException {
		public HIDDeviceNotFoundException(final String message) {
			super(message);
		}
	}

	public HiDeviceException(final String message) {
		super(message);
	}
}
