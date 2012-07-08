package de.holger_oehm.usb.hid;

import java.util.Formatter;

public class USBAddress {
	private final int vendorId;
	private final int productId;

	public USBAddress(final short vendorId, final short productId) {
		this(0x0000ffff & vendorId, 0x0000ffff & productId);
	}

	public USBAddress(final int vendorId, final int productId) {
		if (!validateShortId(vendorId)) {
			throw new IllegalArgumentException("vendorId must be between 0 and " + (Short.MAX_VALUE - Short.MIN_VALUE) + ": "
					+ vendorId);
		}
		if (!validateShortId(productId)) {
			throw new IllegalArgumentException("productId must be between 0 and " + (Short.MAX_VALUE - Short.MIN_VALUE) + ": "
					+ productId);
		}

		this.vendorId = vendorId;
		this.productId = productId;
	}

	private boolean validateShortId(final int value) {
		return value >= 0 && value <= (Short.MAX_VALUE - Short.MIN_VALUE);
	}

	public int getVendorId() {
		return vendorId;
	}

	public int getProductId() {
		return productId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + productId;
		result = prime * result + vendorId;
		return result;
	}

	@Override
	public boolean equals(final Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (getClass() != obj.getClass()) {
			return false;
		}
		final USBAddress other = (USBAddress) obj;
		if (productId != other.productId) {
			return false;
		}
		if (vendorId != other.vendorId) {
			return false;
		}
		return true;
	}

	@Override
	public String toString() {
		final StringBuilder addressText = new StringBuilder();
		try (Formatter formatter = new Formatter(addressText);) {
			formatter.format("0x%04x:0x%04x", vendorId, productId);
		}
		return addressText.toString();
	}
}