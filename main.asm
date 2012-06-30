; eXtreme Feedback Device
; USB connected device which switches some LEDs on and off
; main routine and configuration
#include <p18f2550.inc>
#include "usb_defs.inc"

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
	extern	SendKeyBuffer
; wait.asm
	extern	waitMilliSeconds

;**************************************************************
; imported variables
	extern	Key_buffer

;**************************************************************
; local definitions
#define TIMER0H_VAL         0xFE
#define TIMER0L_VAL         0x20

;**************************************************************
; local data
main_udata		UDATA
COUNTER			RES	1

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

	movlw	b'11110000'		; PORTA 4 lsbs go to LEDs 1 - 4
	movwf	TRISA, ACCESS
	movf	TRISB, W, ACCESS
	iorlw	b'00010000'		; make RB4 an input (SW2)
	movwf	TRISB, ACCESS

        movlw		TIMER0H_VAL
	movwf		TMR0H, ACCESS
        movlw		TIMER0L_VAL
	movwf		TMR0L, ACCESS
	movlw		0x97
	movwf		T0CON, ACCESS	; set prescaler for Timer0 for 1:256 scaling
					;	(Timer0 will go off every ~10 ms )
		
	call		InitUSB		; initialize the USB registers and serial interface engine

	call		WaitConfiguredUSB

	banksel		COUNTER
	clrf		COUNTER, BANKED

mainLoop
	; service usb requests as long as timer0 runs
	call		ServiceUSB
	btfss		INTCON, T0IF, ACCESS
	goto		mainLoop

	bcf		INTCON, T0IF, ACCESS	; clear Timer0 interrupt flag
	movlw		TIMER0H_VAL
	movwf		TMR0H, ACCESS
	movlw		TIMER0L_VAL
	movwf		TMR0L, ACCESS

	btfss		PORTB, 4, ACCESS	; keys requested?
	goto		mainLoop

	banksel		BD1IST
	btfsc		BD1IST, UOWN, BANKED	; check to see if the PIC owns the EP1 IN buffer
	goto		mainLoop

	movlw		high (Key_buffer+2)
	movwf		FSR0H, ACCESS
	movlw		low (Key_buffer+2)
	movwf		FSR0L, ACCESS		; set FSR0 to point to start of keycodes in Key_buffer
	call		GetNextKeycode		; get the next keycode and...
	movwf		POSTINC0		; ...put it into Key_buffer
	clrf		INDF0
	incf		COUNTER, F, BANKED	; increment COUNTER...
	movlw		0x07
	andwf		COUNTER, F, BANKED	; ...modulo 8
	call		SendKeyBuffer

	goto mainLoop

GetNextKeycode
	movlw		upper KeycodeTable
	movwf		TBLPTRU, ACCESS
	movlw		high KeycodeTable
	movwf		TBLPTRH, ACCESS
	movlw		low KeycodeTable
	banksel		COUNTER
	addwf		COUNTER, W, BANKED
	btfss		STATUS, C, ACCESS
	goto		addressCalculated
	incfsz		TBLPTRH, F, ACCESS
	goto		addressCalculated
	incf		TBLPTRU, F, ACCESS
addressCalculated
	movwf		TBLPTRL, ACCESS
	tblrd*
	movf		TABLAT, W, ACCESS
	return

KeycodeTable
db	0x09, 0x12	; USB keycode for 'f', USB keycode for 'o'
db	0x00, 0x12	; USB keycode for indicating no event, USB keycode for 'o'
db	0x05, 0x04	; USB keycode for 'b', USB keycode for 'a'
db	0x15, 0x2C	; USB keycode for 'r', USB keycode for ' '

			END
