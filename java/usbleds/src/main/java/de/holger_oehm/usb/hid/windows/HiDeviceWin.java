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
import com.sun.jna.platform.win32.Kernel32;
import com.sun.jna.platform.win32.SetupApi;
import com.sun.jna.platform.win32.WinBase;
import com.sun.jna.platform.win32.WinNT;
import com.sun.jna.platform.win32.WinNT.HANDLE;
import com.sun.jna.ptr.IntByReference;

import de.holger_oehm.usb.hid.HiDeviceException.HIDDeviceNotFoundException;
import de.holger_oehm.usb.hid.HiDevice;
import de.holger_oehm.usb.hid.USBAddress;

public class HiDeviceWin implements HiDevice {

    static {
        setPreserveLastError(true);
    }

    private static final int ERROR_NO_MORE_ITEMS = 259;

    private final USBAddress address;
    private HANDLE handle = WinBase.INVALID_HANDLE_VALUE;

    public HiDeviceWin(final USBAddress address) {
        this.address = address;
        open();
    }

    @SuppressWarnings("deprecation")
    private static void setPreserveLastError(final boolean bool) {
        Native.setPreserveLastError(bool);
    }

    private void open() {
        final Guid.GUID.ByReference hidDevices = getHidDevicesGuid();
        final HANDLE deviceInfoList = SetupApi.INSTANCE.SetupDiGetClassDevs(hidDevices, null, null,
                SetupApi.DIGCF_DEVICEINTERFACE | SetupApi.DIGCF_PRESENT);
        if (WinBase.INVALID_HANDLE_VALUE == deviceInfoList) {
            throw new LastErrorException(Native.getLastError());
        }

        try {
            for (int index = 0;; index++) {
                // Loop exits with HIDDeviceNotFoundException
                final String devicePath = getDevicePath(hidDevices, deviceInfoList, index);
                final WinNT.HANDLE deviceHandle = getDeviceHandle(devicePath);
                final USBAddress usbAddress = getUsbAddress(deviceHandle);
                if (usbAddress.equals(address)) {
                    handle = deviceHandle;
                    break;
                } else {
                    Kernel32.INSTANCE.CloseHandle(deviceHandle);
                }
            }
        } finally {
            SetupApi.INSTANCE.SetupDiDestroyDeviceInfoList(deviceInfoList);
        }
    }

    private Guid.GUID.ByReference getHidDevicesGuid() {
        final Guid.GUID.ByReference hidDevices = new Guid.GUID.ByReference();
        Hid.INSTANCE.HidD_GetHidGuid(hidDevices);
        return hidDevices;
    }

    private USBAddress getUsbAddress(final WinNT.HANDLE deviceHandle) {
        final HidAttributes attributes = new HidAttributes();
        Hid.INSTANCE.HidD_GetAttributes(deviceHandle, attributes);
        return new USBAddress(attributes.vendorID, attributes.productID);
    }

    private WinNT.HANDLE getDeviceHandle(final String devicePath) {
        final int shareMode = WinNT.FILE_SHARE_READ | WinNT.FILE_SHARE_WRITE;
        return Kernel32.INSTANCE.CreateFile(devicePath, 0, shareMode, null, WinNT.OPEN_EXISTING, WinNT.FILE_FLAG_OVERLAPPED,
                (WinNT.HANDLE) null);
    }

    private String getDevicePath(final Guid.GUID.ByReference hidDevices, final HANDLE hDevInfo, final int index)
            throws HIDDeviceNotFoundException {
        final SetupApi.SP_DEVICE_INTERFACE_DATA.ByReference deviceInterfaceData = new SetupApi.SP_DEVICE_INTERFACE_DATA.ByReference();
        if (!SetupApi.INSTANCE.SetupDiEnumDeviceInterfaces(hDevInfo, null, hidDevices, index, deviceInterfaceData)) {
            final int errno = Native.getLastError();
            if (errno == ERROR_NO_MORE_ITEMS) {
                throw new HIDDeviceNotFoundException("no device with address " + address + " found");
            }
            throw new LastErrorException(errno);
        }
        // get length of path
        final IntByReference requestLength = new IntByReference();
        SetupApi.INSTANCE.SetupDiGetDeviceInterfaceDetail(hDevInfo, deviceInterfaceData, null, 0, requestLength, null);
        // prepare actual result data structure
        final DeviceInterfaceDetailData detailData = new DeviceInterfaceDetailData(requestLength.getValue());
        detailData.write();
        if (!SetupApi.INSTANCE.SetupDiGetDeviceInterfaceDetail(hDevInfo, deviceInterfaceData, detailData.getPointer(),
                requestLength.getValue(), requestLength, null)) {
            final int errno = Native.getLastError();
            throw new LastErrorException(errno);
        }
        detailData.read();
        return Native.toString(detailData.devicePath);
    }

    private boolean isOpened() {
        return handle != WinBase.INVALID_HANDLE_VALUE;
    }

    @Override
    public void setReport(final int reportNumber, final byte[] report) {
        if (!isOpened()) {
            throw new IllegalStateException("not opened");
        }
        final byte[] buffer = new byte[report.length + 1];
        buffer[0] = (byte) reportNumber;
        System.arraycopy(report, 0, buffer, 1, report.length);
        Hid.INSTANCE.HidD_SetOutputReport(handle, buffer, new NativeLong(buffer.length));
    }

    @Override
    public void close() {
        final HANDLE deviceHandle = handle;
        handle = WinBase.INVALID_HANDLE_VALUE;
        Kernel32.INSTANCE.CloseHandle(deviceHandle);
    }
}
