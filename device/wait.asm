; eXtreme Feedback Device
; USB connected device which switches some LEDs on and off
; wait routines: busy waiting for defined ms delay
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

;**************************************************************
; exported subroutines
	GLOBAL	waitMilliSeconds
	GLOBAL	waitSeconds

;**************************************************************
; local data
			UDATA_OVR
waitSecondsValue	RES 1
waitMSeconds		RES 1
waitInner		RES 1
waitInnerMost		RES 1

;**************************************************************
; code
wait_code		CODE

;*****************************************************************
; wait for some milli seconds
; calculated for 24 MHz CPU clock (6,000,000 instructions per second)
; 1 ms is 6000 instructions
; time calculation: 			; instruction
					;	innerMostLoop
					;		innerLoop
					;			outerLoop
					;				total
waitMilliSeconds			; 2	-	-	-	2
	BANKSEL	waitMSeconds		; 1	-	-	-	3
	movwf	waitMSeconds		; 1	-	-	-	4
outerLoop
	movlw	D'52'			; 1	-	-	1	5
	movwf	waitInner		; 1	-	-	2	6
innerLoop
	movlw	D'25'			; 1	-	1	3	7
	movwf	waitInnerMost		; 1	-	2	4	8
innerMostLoop
	nop				; 1	1
	nop				; 1	2
	decfsz	waitInnerMost,F		; 1	3	
	goto	innerMostLoop		; 2	5	102
	; decfsz-branch			; 2	4	106
	nop				; 1	-	107
	nop				; 1	-	108
	nop				; 1	-	109
	nop				; 1	-	110
	nop				; 1	-	111
	nop				; 1	-	112
	decfsz	waitInner,F		; 1	-	113
	goto	innerLoop		; 2	-	115	5869
	; decfsz-branch			; 2	-	114	5983
	nop				; 1	-	-	5984
	nop				; 1	-	-	5985
	nop				; 1	-	-	5986
	nop				; 1	-	-	5987
	nop				; 1	-	-	5988
	decfsz	waitMSeconds,F		; 1	-	-	5989
	goto	goOuterLoop		; 2	-	-	5991
	; decfsz-branch			; 2	-	-	5990	5998
	return				; 2	-	-	-	6000

goOuterLoop	; indirection of this jump inserts 5 cycles
	nop				; 1	-	-	5992	6000
	nop				; 1	-	-	5993	6001
	nop				; 1	-	-	5994	6002
	goto	outerLoop		; 2	-	-	5996	6004

; wait for seconds
waitSeconds
	; no need for cycle counting this time. The duration of this routine
	; takes a bit to long, but the error is in the range of ppms
	BANKSEL	waitSecondsValue	; 1		-		1
	movwf	waitSecondsValue	; 1		-		2
waitSecondsLoop
	movlw	D'250'			; 1		1	
	call	waitMilliSeconds	; 1,500,000	1,500,001
	movlw	D'250'			; 1		1,500,002
	call	waitMilliSeconds	; 1,500,000	3,000,002
	movlw	D'250'			; 1		3,000,003
	call	waitMilliSeconds	; 1,500,000	4,500,003
	movlw	D'250'			; 1		4,500,004
	call	waitMilliSeconds	; 1,500,000	6,000,005
	decfsz	waitSecondsValue,F	; 1		6,000,006
	goto	waitSecondsLoop		; 2		6,000,008	6,000,010
	; dscfsz-branch			; 1		6,000,007
	return				; 2		6,000,009


	END
