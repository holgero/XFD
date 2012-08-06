# eXtreme Feedback Device
# USB connected device which switches some LEDs on and off
# Makefile, creates usbleds executable from sources
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

CC = g++
CFLAGS = -Wall
LIBS = -lusb
SRC = main.cpp USBLeds.cpp USBLeds.hpp LED.cpp LED.hpp

all: usbleds

usbleds: $(SRC)
	$(CC) $(CFLAGS) -o usbleds $+ $(LIBS)

clean:
	rm -f usbleds

.PHONY: all clean
