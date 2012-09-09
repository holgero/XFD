; eXtreme Feedback Device
; USB connected device which switches some LEDs on and off
; interrupt vectors when no bootloader is in place
;
; Copyright (C) 2012 Holger Oehm
; This program is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include <p18f13k50.inc>

;**************************************************************
; imported subroutines
	extern	main
	extern	highPriorityInterrupt
	extern	lowPriorityInterrupt

;**************************************************************
; real vectors

realResetvector                 ORG     0x0000
        goto    main

realHiprio_interruptvector      ORG     0x0008
        goto    highPriorityInterrupt

realLowprio_interruptvector     ORG     0x0018
        goto    lowPriorityInterrupt

				END
