# eXtreme Fedback Device

The aim is to bring the feedback from the continous integration build
faster to the developer.
For this a microcontroller (PIC18Fxx5x) controls some indicators (typically 
three LEDs mimicing a traffic light). The host runs a java program that
polls the CI build server and tells the microcontroller via usb which
LED(s) to light.

The device has its own official USB address (0x1d50:0x6039), thanks
to Openmoko Inc. (see
http://wiki.openmoko.org/wiki/USB_Product_IDs#USB_Vendor_and_Product_IDs ).

The USB firmware is now extracted in the spin-off project
https://github.com/holgero/PicUsbFirmware . It is used as a git submodule
in this project.

## Project Setup

Clone the sources and initialize the submodule:
$ git clone git://github.com/holgero/XFD.git
$ cd XFD
$ git submodule init
$ git submodule update

## Building

To build: Run make in the top level directory like this:
$ make

Needs to compile: make, gcc++, javac, maven, gputils
Needs at runtime: java, libusb-1.0 (on Linux), WinUSB driver (on Windows)

You will find the firmware under device/XFD.hex, flash your PIC with it.

The program for your host will be a jar file under buildmonitor/target
named buildmonitor-*-jar-with-dependencies.jar. Start it with a command
line like this:

$ java -jar buildmonitor-*-jar-with-dependencies.jar http://jenkins.my.domain:8080/view/BuildViewToWatch

Note: On Windows (before Windows 8) you need to install the WinUSB driver
for generic USB devices once before you can use it. You can use Zadig
(https://github.com/pbatard/libwdi/wiki/Zadig) for that purpose.


## Contents

Directories:
firmware		git submodule contains the USB firmware
device			main routine and USB descriptor for this device
host			C++ executable and some demo scripts, mainly used
			to test the hardware and firmware (Linux only)
java/usbleds		usb leds java driver (tested on Linux and Windows 7)
java/buildmonitor	main program with the build monitor
hardware		device hardware

See also the file CREDITS.

Branches:
master:		main branch, uses PIC18F13K50
18f2550:	a secondary branch, based on PIC18F2550, mostly for reference
		and for sentimental reasons (I started in this branch).
hid		a different approach to access the device on windows:
		it is declared as a HID and accessed with the HID.DLL

## Binaries Download and CI Build

A CI build of this project runs at CloudBees: https://xfd.ci.cloudbees.com/

The latest snapshot build is archived to this repository https://repository-xfd.forge.cloudbees.com/snapshot.

You can download the latest snapshot build results from the snapshot repository or from the build job itself (if it is currently enabled).

## License

    Copyright (C) 2012  Holger Oehm

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
