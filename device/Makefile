# eXtreme Feedback Device
# USB connected device which switches some LEDs on and off
# Makefile, creates XFD.hex file from sources
#
# Copyright (C) 2012 Holger Oehm
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

OBJECTS=usb.o wait.o main.o

%.o : %.asm
	gpasm -c -p p18f13k50 -r dec -w 2 $<

all: XFD.hex

XFD.hex: $(OBJECTS)
	gplink -o XFD.hex -a inhx32 -m $(OBJECTS)

clean:
	rm -f *.o *.map *.lst *.cod *.hex

.PHONY: all clean
