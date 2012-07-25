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

package de.holger_oehm.usb.hid.windows;

import com.sun.jna.LastErrorException;
import com.sun.jna.Native;
import com.sun.jna.NativeLong;
import com.sun.jna.platform.win32.Guid;
import com.sun.jna.platform.win32.WinNT;
import com.sun.jna.win32.W32APIOptions;

/**
 * Native "hid.dll" library methods.
 */
public interface Hid extends WinNT {
	Hid INSTANCE = (Hid) Native.loadLibrary("hid", Hid.class, W32APIOptions.UNICODE_OPTIONS);

	/**
	 * Retrieve the device interfaceGUID for HIDClass devices. JNA wrapper for
	 * "void __stdcall HidD_GetHidGuid( __out LPGUID HidGuid );".
	 * 
	 * @param guid
	 *            Pointer to a GUID buffer. On return it will contain the device
	 *            interface GUID for HIDClass devices.
	 * @throws LastErrorException
	 */
	void HidD_GetHidGuid(Guid.GUID.ByReference guid) throws LastErrorException;

	/**
	 * Returns the attributes of a hid device<. JNA wrapper for "BOOLEAN
	 * __stdcall HidD_GetAttributes( __in HANDLE HidDeviceObject, __out
	 * PHIDD_ATTRIBUTES Attributes );".
	 * 
	 * @param handle
	 *            Open handle of the HID device.
	 * @param attributes
	 *            Pointer to a HIDD_ATTRIBUTES buffer. On return it contains the
	 *            attributes of the hid device.
	 * @return <code>true</code> if successful.
	 * @throws LastErrorException
	 */
	int HidD_GetAttributes(WinNT.HANDLE handle, HidAttributes attributes) throws LastErrorException;

	/**
	 * Send an output report to a hid device. JNA wrapper for "BOOLEAN __stdcall
	 * HidD_SetOutputReport( __in HANDLE HidDeviceObject, __in PVOID
	 * ReportBuffer, __in ULONG ReportBufferLength );".
	 * 
	 * @param handle
	 *            Open handle to a HID device.
	 * @param report
	 *            Byte 0 contains the report id or zero. The remaining bytes are
	 *            sent as report to the device.
	 * @param reportBufferLength
	 *            Specifies the size, in bytes, of the report buffer. That is
	 *            the size of the report + 1 (for the report id).
	 * @return <code>true</code> if successful.
	 * @throws LastErrorException
	 */
	boolean HidD_SetOutputReport(WinNT.HANDLE handle, byte[] report, NativeLong reportBufferLength) throws LastErrorException;
}
