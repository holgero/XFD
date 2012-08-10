/*
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

package de.holger_oehm.usb.device;

import java.util.Formatter;

public class USBAddress {
    private final int vendorId;
    private final int productId;

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

    public short getVendorId() {
        return toUnsignedShortRepresentation(vendorId);
    }

    private short toUnsignedShortRepresentation(final int id) {
        if (id > Short.MAX_VALUE) {
            return (short) (-id);
        }
        return (short) id;
    }

    public short getProductId() {
        return toUnsignedShortRepresentation(productId);
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
