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

#include <p18f2550.inc>

;**************************************************************
; configuration
        config PLLDIV   = 5		; crystal 20 Mhz
        config CPUDIV   = OSC3_PLL4	; cpu     24 MHz
        config USBDIV   = 2		; USB clock from PLL/2
        config FOSC     = HSPLL_HS	; HS, PLL enabled, HS used by USB
        config FCMEN    = OFF
        config IESO     = OFF
        config PWRT     = OFF
        config BOR      = ON
        config BORV     = 3
        config VREGEN   = ON		; USB voltage regulator enable
        config WDT      = OFF
        config WDTPS    = 32768
        config MCLRE    = ON
        config LPT1OSC  = OFF
        config PBADEN   = OFF
        config CCP2MX   = ON
        config STVREN   = ON
        config LVP      = OFF
        config DEBUG    = OFF
        config XINST    = OFF
        config CP0      = OFF
        config CP1      = OFF
        config CP2      = OFF
        config CP3      = OFF
        config WRT3     = OFF
        config EBTR3    = OFF
        config CPB      = OFF
        config CPD      = OFF
        config WRT0     = OFF
        config WRT1     = OFF
        config WRT2     = OFF
        config WRTB     = OFF
        config WRTC     = OFF
        config WRTD     = OFF
        config EBTR0    = OFF
        config EBTR1    = OFF
        config EBTR2    = OFF
;**************************************************************
; imported subroutines
; usb.asm
	extern	InitUSB
	extern	WaitConfiguredUSB
	extern	ServiceUSB
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

;**************************************************************
; vectors
resetvector		ORG	0x0800
	goto	Main
hiprio_interruptvector	ORG	0x0808
	goto	$
lowprio_interruptvector	ORG	0x0818
	goto	$

;**************************************************************
; main code
main_code		CODE	0x01600
Main
	movlw	1			; wait a msec
	call	waitMilliSeconds	
	clrf	PORTA, ACCESS
	movlw	0x0F
	movwf	ADCON1, ACCESS		; set up PORTA to be digital I/Os
	movlw	b'11111000'		; LEDs on RA0,1,2
	movwf	TRISA, ACCESS

	clrf	PORTB, ACCESS
	movlw	b'11100000'		; LEDs on 5 LSBs of Port B
	movwf	TRISB, ACCESS

        movlw	TIMER0H_VAL
	movwf	TMR0H, ACCESS
        movlw	TIMER0L_VAL
	movwf	TMR0L, ACCESS
	movlw	0x97
	movwf	T0CON, ACCESS		; set prescaler for Timer0 for 1:256 scaling
					;	(Timer0 will go off every ~10 ms )
		
	call	InitUSB			; initialize the USB module

;	CAVE: remove for production
;	goto	mainLoop	; makes sense only for simulation, do not wait for USB
;	CAVE: remove for production

	call	WaitConfiguredUSB

	banksel	noSignFromHostL
	clrf	noSignFromHostL
	clrf	noSignFromHostH
	clrf	blinkenLights

mainLoop
	banksel	USB_received
	bcf	USB_received,0,BANKED
waitTimerLoop
	; service usb requests as long as timer0 runs
	call	ServiceUSB
	btfss	INTCON, T0IF, ACCESS
;	CAVE: uncomment for production
	goto	waitTimerLoop

	bcf	INTCON, T0IF, ACCESS	; clear Timer0 interrupt flag
	movlw	TIMER0H_VAL
	movwf	TMR0H, ACCESS
	movlw	TIMER0L_VAL
	movwf	TMR0L, ACCESS
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
	clrf	PORTB,ACCESS		; all off
	movlw	0x07			; also all off (inverted)
	movwf	PORTA,ACCESS
	goto	mainLoop

notYetBlinking
	incf	noSignFromHostH,F,BANKED
	btfss	noSignFromHostH,5,BANKED; 64*256*10ms ~= 160 seconds nothing from the host
	goto	mainLoop		; not yet long enough
yellowOn
	clrf	blinkenLights,BANKED
	bsf	blinkenLights,7,BANKED
	movlw	0x05			; all off, but yellow
	movwf	PORTA,ACCESS
	movlw	0x02			; yellow on
	movwf	PORTB,ACCESS
	goto	mainLoop

	; set leds according to led state
setled		macro	index
	btfss	LED_states + index, 0, BANKED
	bcf	PORTB, index, ACCESS	; bit 0 cleared, clear port bit
	btfsc	LED_states + index, 0, BANKED
	bsf	PORTB, index, ACCESS	; bit 0 set, set port bit
	endm

	; inverted logic for LEDs on PORTA (pin 0 -> led lights)
setsecondled	macro	index
	btfss	LED_states + index, 0, BANKED
	bsf	PORTA, index, ACCESS	; bit 0 cleared, set port bit
	btfsc	LED_states + index, 0, BANKED
	bcf	PORTA, index, ACCESS	; bit 0 set, clear port bit
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
	setled	3	; blue
	setled	4	; white

	setsecondled	0
	setsecondled	1
	setsecondled	2

	goto mainLoop

			END
