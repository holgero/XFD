; eXtreme Feedback Device
; USB connected device which switches some LEDs on and off
; main routine and configuration
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
; configuration
	config USBDIV	= ON
	config FOSC	= HS
	config PLLEN	= ON
        config FCMEN	= OFF
        config IESO     = OFF
	config WDTEN	= OFF
        config WDTPS    = 32768
        config MCLRE    = ON
        config STVREN   = ON
        config LVP      = OFF
        config XINST    = OFF
        config CP0      = OFF
        config CP1      = OFF
        config CPB      = OFF
        config CPD      = OFF
        config WRT0     = OFF
        config WRT1     = OFF
        config WRTB     = OFF
        config WRTC     = OFF
        config WRTD     = OFF
        config EBTR0    = OFF
        config EBTR1    = OFF
;**************************************************************
; imported subroutines
; usb.asm
	extern	InitUSB
	extern	WaitConfiguredUSB
	extern	ServiceUSB
	extern	enableUSBInterrupts
; wait.asm
	extern	waitMilliSeconds
	extern	USB_received

;**************************************************************
; imported variables
; usb.asm
	extern	LED_states

;**************************************************************
; local definitions
#define TIMER0H_VAL         0xFE
#define TIMER0L_VAL         0x20

;**************************************************************
; local data
main_udata		UDATA
noSignFromHostL		RES	1
noSignFromHostH		RES	1
blinkenLights		RES	1
; low prio interrupt has to save registers for itself
STATUS_temp_LP		RES	1
BSR_temp_LP		RES	1
FSR0H_temp_LP		RES	1
FSR0L_temp_LP		RES	1
FSR1H_temp_LP		RES	1
FSR1L_temp_LP		RES	1
FSR2H_temp_LP		RES	1
FSR2L_temp_LP		RES	1
; high prio interrupt needs to save only FSRn
FSR0H_temp_HP		RES	1
FSR0L_temp_HP		RES	1
FSR1H_temp_HP		RES	1
FSR1L_temp_HP		RES	1
FSR2H_temp_HP		RES	1
FSR2L_temp_HP		RES	1
;**************************************************************
; local data in accessbank
main_accessbank		UDATA_ACS
W_temp_LP		RES	1

;**************************************************************
; real vectors (not needed if a bootloader is in place)
realResetvector			ORG	0x0000
	goto	main
realHiprio_interruptvector	ORG	0x0008
	goto	highPriorityInterrupt
realLowprio_interruptvector	ORG	0x0018
	goto	lowPriorityInterrupt

;**************************************************************
; vectors
resetvector		ORG	0x0800
	goto	main
hiprio_interruptvector	ORG	0x0808
	goto	highPriorityInterrupt
lowprio_interruptvector	ORG	0x0818
	goto	lowPriorityInterrupt

;**************************************************************
; main code
main_code		CODE	0x01600

highPriorityInterrupt
	movff	FSR0H, FSR0H_temp_HP
	movff	FSR0L, FSR0L_temp_HP
	movff	FSR1H, FSR1H_temp_HP
	movff	FSR1L, FSR1L_temp_HP
	movff	FSR2H, FSR2H_temp_HP
	movff	FSR2L, FSR2L_temp_HP

;	call	HPinterruptHandler

	movff	FSR2L_temp_HP, FSR2L
	movff	FSR2H_temp_HP, FSR2H
	movff	FSR1L_temp_HP, FSR1L
	movff	FSR1H_temp_HP, FSR1H
	movff	FSR0L_temp_HP, FSR0L
	movff	FSR0H_temp_HP, FSR0H
	retfie	FAST

lowPriorityInterrupt
	movff	STATUS, STATUS_temp_LP
	movwf	W_temp_LP, ACCESS
	movff	BSR, BSR_temp_LP
	movff	FSR0H, FSR0H_temp_LP
	movff	FSR0L, FSR0L_temp_LP
	movff	FSR1H, FSR1H_temp_LP
	movff	FSR1L, FSR1L_temp_LP
	movff	FSR2H, FSR2H_temp_LP
	movff	FSR2L, FSR2L_temp_LP

;	dispatch interrupt
	btfss	PIR2, USBIF, ACCESS
	goto	dispatchLowPrioInterrupt_usbDone
	call	ServiceUSB
	bcf	PIR2, USBIF, ACCESS

dispatchLowPrioInterrupt_usbDone

	movff	FSR2L_temp_LP, FSR2L
	movff	FSR2H_temp_LP, FSR2H
	movff	FSR1L_temp_LP, FSR1L
	movff	FSR1H_temp_LP, FSR1H
	movff	FSR0L_temp_LP, FSR0L
	movff	FSR0H_temp_LP, FSR0H
	movff	BSR_temp_LP, BSR
	movf	W_temp_LP, W, ACCESS
	movff	STATUS_temp_LP, STATUS
	retfie

main
	movlw	3			; wait a bit: 3 ms
	call	waitMilliSeconds

	clrf	LATB, ACCESS
	movlw	b'10001111'		; LEDs on Port B, RB<4:6>
	movwf	TRISB, ACCESS

        movlw	TIMER0H_VAL
	movwf	TMR0H, ACCESS
        movlw	TIMER0L_VAL
	movwf	TMR0L, ACCESS
	movlw	0x97
	movwf	T0CON, ACCESS		; set prescaler for Timer0 for 1:256 scaling
					;	(Timer0 will go off every ~10 ms )
		
	call	InitUSB			; initialize the USB module

	call	WaitConfiguredUSB

	; set up interrupt configuration
	clrf	INTCON, ACCESS		; all interrupts off
	clrf	INTCON3, ACCESS		; external interrupts off
	clrf	PIR1, ACCESS		; clear interrupt sources
	clrf	PIR2, ACCESS		; clear interrupt sources
	clrf	PIE1, ACCESS		; disable external interrupts
	clrf	PIE2, ACCESS		; disable external interrupts
	clrf	IPR1, ACCESS		; set priority to low
	clrf	IPR2, ACCESS		; set priority to low
	
	bsf	RCON, IPEN, ACCESS	; enable interrupt priority
	
	call	enableUSBInterrupts	; enable interrupts from the usb module
	bsf	PIE2, USBIF		; enable USB interrupts
	bsf	INTCON, GIEH		; enable high prio interrupt vector
	bsf	INTCON, GIEL		; enable low prio interrupt vector
	
	banksel	noSignFromHostL
	clrf	noSignFromHostL, BANKED
	clrf	noSignFromHostH, BANKED
	clrf	blinkenLights, BANKED
	movlw	b'01110000'		; switch all leds off (inverted)
	movwf	LATB,ACCESS

mainLoop
	banksel	USB_received
	bcf	USB_received,0,BANKED
waitTimerLoop
	btfss	INTCON, T0IF, ACCESS
	goto	waitTimerLoop

	bcf	INTCON, T0IF, ACCESS	; clear Timer0 interrupt flag
	movlw	TIMER0H_VAL
	movwf	TMR0H, ACCESS
	movlw	TIMER0L_VAL
	movwf	TMR0L, ACCESS
	banksel	USB_received
	btfsc	USB_received,0,BANKED
	goto	setLEDs

	; nothing new from the host
	; first divider: 10ms * 256 = 2.5s
	banksel	noSignFromHostL
	incfsz	noSignFromHostL, BANKED
	goto	mainLoop

	btfss	blinkenLights,7,BANKED	; already blinking?
	goto	notYetBlinking		; no not yet
	incf	blinkenLights,F,BANKED
	btfsc	blinkenLights,1,BANKED	; 2*256*10ms: changes every 5.2s (not true, it is more like 10s, but dont know why... probably the timer fires only every 20ms???)
	goto	yellowOn
	movlw	b'01110000'		; all off (inverted)
	movwf	LATB,ACCESS
	goto	mainLoop

notYetBlinking
	incf	noSignFromHostH,F,BANKED
	btfss	noSignFromHostH,5,BANKED; 64*256*10ms ~= 160 seconds nothing from the host
	goto	mainLoop		; not yet long enough
yellowOn
	clrf	blinkenLights,BANKED
	bsf	blinkenLights,7,BANKED
	bcf	LATB,5,ACCESS		; yellow on: clear RB5
	goto	mainLoop

	; set leds according to led state, inverted logic. Use bits 4:6
setled	macro	index
	btfss	LED_states + index, 0, BANKED
	bsf	LATB, index + 4, ACCESS	; bit 0 cleared, set port bit
	btfsc	LED_states + index, 0, BANKED
	bcf	LATB, index + 4, ACCESS	; bit 0 set, clear port bit
	endm

setLEDs
	banksel	noSignFromHostL
	clrf	noSignFromHostL, BANKED
	clrf	noSignFromHostH, BANKED
	clrf	blinkenLights, BANKED

	banksel	LED_states
	setled	0	; red
	setled	1	; yellow
	setled	2	; green

	goto mainLoop

			END
