; eXtreme Feedback Device
; USB connected device which switches some LEDs on and off
; main routine and configuration
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
	; service usb requests as long as timer0 runs
	call	ServiceUSB
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
