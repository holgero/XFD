# eXtreme Feedback Device
# USB connected device which switches some LEDs on and off
# Top level Makefile, creates device firmware, C++ test program and
# java main program.
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

all: checkVIDPID device host java

checkVIDPID:
	@test "$(VID)" || ( echo "ERROR: missing VID"; exit 1 )
	@test "$(PID)" || ( echo "ERROR: missing PID"; exit 1 )
	@echo "Building with VID:PID=$(VID):$(PID)"

device:
	$(MAKE) -C device VID=$(VID) PID=$(PID) clean all

host:
	$(MAKE) -C host VID=$(VID) PID=$(PID) clean all

java:
	( cd java; \
	  mkdir -p usbleds/src/main/resources; \
	  echo "vendor.id=$(VID)" > usbleds/src/main/resources/address.properties; \
	  echo "product.id=$(PID)" >> usbleds/src/main/resources/address.properties; \
	  mvn clean install )

.PHONY: all checkVIDPID device host java
