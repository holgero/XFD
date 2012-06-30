;**************************************************************
; usb routines
; firmware for the built in usb device

;**************************************************************
; includes
#include <p18f2550.inc>
#include "usb_defs.inc"
#include "ENGR2210.inc"

;**************************************************************
; exported subroutines
	global	InitUSB
	global	ServiceUSB
	global	SendKeyBuffer
	global	WaitConfiguredUSB

;**************************************************************
; exported variables
	global	Key_buffer

;**************************************************************
; local data
usb_udata		UDATA
USB_buffer_desc		RES	4
USB_buffer_data		RES	8
USB_error_flags		RES	1
USB_curr_config		RES	1
USB_device_status	RES	1
USB_protocol		RES	1
USB_idle_rate		RES	1
USB_dev_req		RES	1
USB_address_pending	RES	1
USB_desc_ptr		RES	1
USB_bytes_left		RES	1
USB_loop_index		RES	1
USB_packet_length	RES	1
USB_USTAT		RES	1
USB_USWSTAT		RES	1
LED_states		RES	1
Key_buffer		RES	8

;**************************************************************
; code section
usb_code		CODE	0x00082a

Descriptor
	movlw		upper Descriptor_begin
	movwf		TBLPTRU, ACCESS
	movlw		high Descriptor_begin
	movwf		TBLPTRH, ACCESS
	movlw		low Descriptor_begin
	banksel		USB_desc_ptr
	addwf		USB_desc_ptr, W, BANKED
	ifset STATUS, C, ACCESS
		incf	TBLPTRH, F, ACCESS
		ifset STATUS, Z, ACCESS
			incf	TBLPTRU, F, ACCESS
		endi
	endi
	movwf		TBLPTRL, ACCESS
	tblrd*
	movf		TABLAT, W
	return

Descriptor_begin
Device
db	0x12, DEVICE			; bLength, bDescriptorType
db	0x10, 0x01			; bcdUSB (low byte), bcdUSB (high byte)
db	0x00, 0x00			; bDeviceClass, bDeviceSubClass
db	0x00, 0x08			; bDeviceProtocl, bMaxPacketSize
db	0xD8, 0x04			; idVendor (low byte), idVendor (high byte)
db	0x02, 0x00			; idProduct (low byte), idProduct (high byte)
db	0x00, 0x00			; bcdDevice (low byte), bcdDevice (high byte)
db	0x01, 0x02			; iManufacturer, iProduct
db	0x00, NUM_CONFIGURATIONS	; iSerialNumber (none), bNumConfigurations
Configuration1
db	0x09, CONFIGURATION		; bLength, bDescriptorType
db	0x22, 0x00			; wTotalLength (low byte), wTotalLength (high byte)
db	NUM_INTERFACES, 0x01		; bNumInterfaces, bConfigurationValue
db	0x00, 0xA0			; iConfiguration (none), bmAttributes
db	0x32, 0x09			; bMaxPower (100 mA), interface1: blength
db	INTERFACE, 0x00			; INTERFACE, 0x00
db	0x00, 0x01			; bAlternateSetting, bNumEndpoints (excluding EP0)
db	0x03, 0x01			; bInterfaceClass (HID code), bInterfaceSubClass (Boot subclass)
db	0x01, 0x00			; bInterfaceProtocol (Keyboard protocol), iInterface (none)
HID1
db	0x09, HID			; bLength, bDescriptorType
db	0x00, 0x01			; bcdHID (low byte), bcdHID (high byte)
db	0x00, 0x01			; bCountryCode (none), bNumDescriptors
db	REPORT, 0x3F			; bDescriptorType, wDescriptorLength (low byte)
db	0x00, 0x07			; wDescriptorLength (high byte), bLength (Endpoint1 descritor starts here)
db	ENDPOINT, 0x81			; bDescriptorType, bEndpointAddress (EP1 IN)
db	0x03, 0x08			; bmAttributes (Interrupt), wMaxPacketSize (low byte)
db	0x00, 0x0A			; wMaxPacketSize (high byte), bInterval (10 ms)
Report1
db	0x05, 0x01			; Usage Page (Generic Desktop),
db	0x09, 0x06			; Usage (Keyboard),
db	0xA1, 0x01			; Collection (Application),
db	0x05, 0x07			;     Usage Page (Key Codes);
db	0x19, 0xE0			;     Usage Minimum (224),
db	0x29, 0xE7			;     Usage Maximum (231),
db	0x15, 0x00			;     Logical Minimum (0),
db	0x25, 0x01			;     Logical Maximum (1),
db	0x75, 0x01			;     Report Size (1),
db	0x95, 0x08			;     Report Count (8),
db	0x81, 0x02			;     Input (Data, Variable, Absolute),   ; Modifier byte
db	0x95, 0x01			;     Report Count (1),
db	0x75, 0x08			;     Report Size (8),
db	0x81, 0x01			;     Input (Constant),                   ; Reserved byte
db	0x95, 0x05			;     Report Count (5),
db	0x75, 0x01			;     Report Size (1),
db	0x05, 0x08			;     Usage Page (Page# for LEDs),
db	0x19, 0x01			;     Usage Minimum (1),
db	0x29, 0x05			;     Usage Maxmimum (5),
db	0x91, 0x02			;     Output (Data, Variable, Absolute),  ; LED report
db	0x95, 0x01			;     Report Count (1),
db	0x75, 0x03			;     Report Size (3),
db	0x91, 0x01			;     Output (Constant),                  ; LED report padding
db	0x95, 0x06			;     Report Count (6),
db	0x75, 0x08			;     Report Size (8),
db	0x15, 0x00			;     Logical Minimum (0),
db	0x25, 0x65			;     Logical Maximum (101),
db	0x05, 0x07			;     Usage Page (Key Codes),
db	0x19, 0x00			;     Usage Minimum (0),
db	0x29, 0x65			;     Usage Maximum (101),
db	0x81, 0x00			;     Input (Data, Array),                ; Key arrays (6 bytes)
db	0xC0				; End Collection
String0
db	String1-String0, STRING		; bLength, bDescriptorType
db	0x09, 0x04			; wLANGID[0] (low byte), wLANGID[0] (high byte)
String1
db	String2-String1, STRING		; bLength, bDescriptorType
db	'M', 0x00			; bString
db	'i', 0x00
db	'c', 0x00
db	'r', 0x00
db	'o', 0x00
db	'c', 0x00
db	'h', 0x00
db	'i', 0x00
db	'p', 0x00
db	' ', 0x00
db	'T', 0x00
db	'e', 0x00
db	'c', 0x00
db	'h', 0x00
db	'n', 0x00
db	'o', 0x00
db	'l', 0x00
db	'o', 0x00
db	'g', 0x00
db	'y', 0x00
db	',', 0x00
db	' ', 0x00
db	'I', 0x00
db	'n', 0x00
db	'c', 0x00
db	'.', 0x00
String2
db	Descriptor_end-String2, STRING	; bLength, bDescriptorType
db	'E', 0x00			; bString
db	'N', 0x00
db	'G', 0x00
db	'R', 0x00
db	' ', 0x00
db	'2', 0x00
db	'2', 0x00
db	'1', 0x00
db	'0', 0x00
db	' ', 0x00
db	'P', 0x00
db	'I', 0x00
db	'C', 0x00
db	'1', 0x00
db	'8', 0x00
db	'F', 0x00
db	'2', 0x00
db	'4', 0x00
db	'5', 0x00
db	'5', 0x00
db	' ', 0x00
db	'U', 0x00
db	'S', 0x00
db	'B', 0x00
db	' ', 0x00
db	'K', 0x00
db	'e', 0x00
db	'y', 0x00
db	'b', 0x00
db	'o', 0x00
db	'a', 0x00
db	'r', 0x00
db	'd', 0x00
Descriptor_end

InitUSB
	clrf	UIE, ACCESS		; mask all USB interrupts
	clrf	UIR, ACCESS		; clear all USB interrupt flags
	; configure USB for low-speed transfers and to use the on-chip transciever and pull-up resistor
	movlw	0x14
	movwf	UCFG, ACCESS
	movlw	0x08
	movwf	UCON, ACCESS		; enable the USB module and its supporting circuitry
	banksel	USB_curr_config
	clrf	USB_curr_config, BANKED
	clrf	USB_idle_rate, BANKED
	clrf	USB_USWSTAT, BANKED	; default to powered state
	movlw	0x01
	movwf	USB_device_status, BANKED
	movwf	USB_protocol, BANKED	; default protocol to report protocol initially
	movlw	NO_REQUEST
	movwf	USB_dev_req, BANKED	; No device requests in process
#ifdef SHOW_ENUM_STATUS
	movlw	b'11110000'		; RD0-3 outputs (LEDs 1-4), RD4-7 inputs
	movwf	TRISD, ACCESS
	movlw	0x01
	movwf	PORTD, ACCESS		; set bit zero to indicate Powered status
#endif
	return

ServiceUSB
	select
		caseset	UIR, UERRIF, ACCESS
			clrf		UEIR, ACCESS
			break
		caseset UIR, SOFIF, ACCESS
			bcf			UIR, SOFIF, ACCESS
			break
		caseset	UIR, IDLEIF, ACCESS
			bcf			UIR, IDLEIF, ACCESS
			break
		caseset UIR, ACTVIF, ACCESS
			bcf			UIR, ACTVIF, ACCESS
			bcf			UCON, SUSPND, ACCESS
#ifdef SHOW_ENUM_STATUS
			movlw		0xF0
			andwf		PORTD, F, ACCESS
			banksel		USB_USWSTAT
			movf		USB_USWSTAT, W, BANKED
			select
				case POWERED_STATE
					movlw	0x01
					break
				case DEFAULT_STATE
					movlw	0x02
					break
				case ADDRESS_STATE
					movlw	0x04
					break
				case CONFIG_STATE
					movlw	0x08
			ends
			iorwf		PORTD, F, ACCESS
#endif
			break
		caseset	UIR, STALLIF, ACCESS
			bcf			UIR, STALLIF, ACCESS
			break
		caseset	UIR, URSTIF, ACCESS
			bsf		PORTA, 1, ACCESS
			banksel		USB_curr_config
			clrf		USB_curr_config, BANKED
			bcf		UIR, TRNIF, ACCESS	; clear TRNIF four times to clear out the USTAT FIFO
			bcf 		UIR, TRNIF, ACCESS
			bcf		UIR, TRNIF, ACCESS
			bcf		UIR, TRNIF, ACCESS
			clrf		UEP0, ACCESS		; clear all EP control registers to disable all endpoints
			clrf		UEP1, ACCESS
			clrf		UEP2, ACCESS
			clrf		UEP3, ACCESS
			clrf		UEP4, ACCESS
			clrf		UEP5, ACCESS
			clrf		UEP6, ACCESS
			clrf		UEP7, ACCESS
			clrf		UEP8, ACCESS
			clrf		UEP9, ACCESS
			clrf		UEP10, ACCESS
			clrf		UEP11, ACCESS
			clrf		UEP12, ACCESS
			clrf		UEP13, ACCESS
			clrf		UEP14, ACCESS
			clrf		UEP15, ACCESS
			banksel		BD0OBC
			movlw		0x08
			movwf		BD0OBC, BANKED
			movlw		low USB_Buffer			; EP0 OUT gets a buffer...
			movwf		BD0OAL, BANKED
			movlw		high USB_Buffer
			movwf		BD0OAH, BANKED			; ...set up its address
			movlw		0x88					; set UOWN bit (USB can write)
			movwf		BD0OST, BANKED
			movlw		low (USB_Buffer+0x08)	; EP0 IN gets a buffer...
			movwf		BD0IAL, BANKED
			movlw		high (USB_Buffer+0x08)
			movwf		BD0IAH, BANKED			; ...set up its address
			movlw		0x08					; clear UOWN bit (MCU can write)
			movwf		BD0IST, BANKED
			clrf		UADDR, ACCESS			; set USB Address to 0
 			clrf		UIR, ACCESS				; clear all the USB interrupt flags
			movlw		ENDPT_CONTROL
			movwf		UEP0, ACCESS			; EP0 is a control pipe and requires an ACK
 			movlw		0xFF					; enable all error interrupts
 			movwf		UEIE, ACCESS
			banksel		USB_USWSTAT
			movlw		DEFAULT_STATE
			movwf		USB_USWSTAT, BANKED
			movlw		0x01
			movwf		USB_device_status, BANKED	; self powered, remote wakeup disabled
#ifdef SHOW_ENUM_STATUS
			movlw		0xF0
			andwf		PORTD, F, ACCESS
			bsf 		PORTD, 1, ACCESS		; set bit 1 of PORTB to indicate Powered state
#endif
			bsf		PORTA, 2, ACCESS
			break
		caseset	UIR, TRNIF, ACCESS
			bsf		PORTA, 3, ACCESS
			movlw		0x04
			movwf		FSR0H, ACCESS
			movf		USTAT, W, ACCESS
			andlw		0x7C					; mask out bits 0, 1, and 7 of USTAT
			movwf		FSR0L, ACCESS
			banksel		USB_buffer_desc
			movf		POSTINC0, W
			movwf		USB_buffer_desc, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_desc+1, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_desc+2, BANKED
			movf		POSTINC0, W
			movwf		USB_buffer_desc+3, BANKED
			movf		USTAT, W, ACCESS
			movwf		USB_USTAT, BANKED		; save the USB status register
			bcf			UIR, TRNIF, ACCESS		; clear TRNIF interrupt flag
#ifdef SHOW_ENUM_STATUS
			andlw		0x18					; extract EP bits
			select
				case EP0
					movlw		0x20
					break
				case EP1
					movlw		0x40
					break
				case EP2
					movlw		0x80
					break
			ends
#endif
			movf		USB_buffer_desc, W, BANKED
			andlw		0x3C					; extract PID bits
			select
				case TOKEN_SETUP
					call		ProcessSetupToken
					break
				case TOKEN_IN
					call		ProcessInToken
					break
				case TOKEN_OUT
					call		ProcessOutToken
					break
			ends
			break
	ends
	return

ProcessSetupToken
	banksel		USB_buffer_data
	movf		USB_buffer_desc+ADDRESSH, W, BANKED
	movwf		FSR0H, ACCESS
	movf		USB_buffer_desc+ADDRESSL, W, BANKED
	movwf		FSR0L, ACCESS
	movf		POSTINC0, W
	movwf		USB_buffer_data, BANKED
	movf		POSTINC0, W
	movwf		USB_buffer_data+1, BANKED
	movf		POSTINC0, W
	movwf		USB_buffer_data+2, BANKED
	movf		POSTINC0, W
	movwf		USB_buffer_data+3, BANKED
	movf		POSTINC0, W
	movwf		USB_buffer_data+4, BANKED
	movf		POSTINC0, W
	movwf		USB_buffer_data+5, BANKED
	movf		POSTINC0, W
	movwf		USB_buffer_data+6, BANKED
	movf		POSTINC0, W
	movwf		USB_buffer_data+7, BANKED
	banksel		BD0OBC
	movlw		0x08
	movwf		BD0OBC, BANKED		; reset the byte count
	movwf		BD0IST, BANKED		; return the in buffer to us (dequeue any pending requests)
	banksel		USB_buffer_data+bmRequestType
	ifl	USB_buffer_data+bmRequestType, EQ, 0x21
		movlw		0xC8
	otherwise
		movlw		0x88
	endi
	banksel		BD0OST
	movwf		BD0OST, BANKED		; set EP0 OUT UOWN back to USB and DATA0/DATA1 packet according to request type
	bcf			UCON, PKTDIS, ACCESS	; assuming there is nothing to dequeue, clear the packet disable bit
	banksel		USB_dev_req
	movlw		NO_REQUEST
	movwf		USB_dev_req, BANKED			; clear the device request in process
	movf		USB_buffer_data+bmRequestType, W, BANKED
	andlw		0x60					; extract request type bits
	select
		case STANDARD
			call		StandardRequests
			break
		case CLASS
			call		ClassRequests
			break
		case VENDOR
			call		VendorRequests
			break
		default
			bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
	ends
	return

StandardRequests
	movf		USB_buffer_data+bRequest, W, BANKED
	select
		case GET_STATUS
			movf		USB_buffer_data+bmRequestType, W, BANKED
			andlw		0x1F					; extract request recipient bits
			select
				case RECIPIENT_DEVICE
					banksel		BD0IAH
					movf		BD0IAH, W, BANKED
					movwf		FSR0H, ACCESS
					movf		BD0IAL, W, BANKED	; get buffer pointer
					movwf		FSR0L, ACCESS
					banksel		USB_device_status
					movf		USB_device_status, W, BANKED	; copy device status byte to EP0 buffer
					movwf		POSTINC0
					clrf		INDF0
					banksel		BD0IBC
					movlw		0x02
					movwf		BD0IBC, BANKED		; set byte count to 2
					movlw		0xC8
					movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
					break
				case RECIPIENT_INTERFACE
					movf		USB_USWSTAT, W, BANKED
					select
						case ADDRESS_STATE
							bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
							break
						case CONFIG_STATE
							ifl USB_buffer_data+wIndex, LT, NUM_INTERFACES
								banksel		BD0IAH
								movf		BD0IAH, W, BANKED
								movwf		FSR0H, ACCESS
								movf		BD0IAL, W, BANKED	; get buffer pointer
								movwf		FSR0L, ACCESS
								clrf		POSTINC0
								clrf		INDF0
								movlw		0x02
								movwf		BD0IBC, BANKED		; set byte count to 2
								movlw		0xC8
								movwf		BD0IST, BANKED					; send packet as DATA1, set UOWN bit
							otherwise
								bsf			UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
							endi
							break
					ends
					break
				case RECIPIENT_ENDPOINT
					movf		USB_USWSTAT, W, BANKED
					select
						case ADDRESS_STATE
							movf		USB_buffer_data+wIndex, W, BANKED	; get EP
							andlw		0x0F					; strip off direction bit
							ifset STATUS, Z, ACCESS				; see if it is EP0
								banksel		BD0IAH
								movf		BD0IAH, W, BANKED	; put EP0 IN buffer pointer...
								movwf		FSR0H, ACCESS
								movf		BD0IAL, W, BANKED
								movwf		FSR0L, ACCESS		; ...into FSR0
								ifset UEP0, EPSTALL, ACCESS
									movlw		0x01
								otherwise
									movlw		0x00
								endi
								movwf		POSTINC0
								clrf		INDF0
								movlw		0x02
								movwf		BD0IBC, BANKED		; set byte count to 2
								movlw		0xC8
								movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
							otherwise
								bsf			UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
							endi
							break
						case CONFIG_STATE
							banksel		BD0IAH
							movf		BD0IAH, W, BANKED		; put EP0 IN buffer pointer...
							movwf		FSR0H, ACCESS
							movf		BD0IAL, W, BANKED
							movwf		FSR0L, ACCESS			; ...into FSR0
							movlw		high UEP0			; put UEP0 address...
							movwf		FSR1H, ACCESS
							movlw		low UEP0
							movwf		FSR1L, ACCESS			; ...into FSR1
							banksel		USB_buffer_data+wIndex
							movf		USB_buffer_data+wIndex, W, BANKED	; get EP and...
							andlw		0x0F				; ...strip off direction bit
							ifclr PLUSW1, EPOUTEN, ACCESS
							andifclr PLUSW1, EPINEN, ACCESS
								bsf			UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
							otherwise
								ifset PLUSW1, EPSTALL, ACCESS
									movlw		0x01
								otherwise
									movlw		0x00
								endi
								movwf		POSTINC0
								clrf		INDF0
								banksel		BD0IBC
								movlw		0x02
								movwf		BD0IBC, BANKED		; set byte count to 2
								movlw		0xC8
								movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
							endi
							break
						default
							bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					ends
					break
				default
					bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
			ends
			break
		case CLEAR_FEATURE
		case SET_FEATURE
			movf		USB_buffer_data+bmRequestType, W, BANKED
			andlw		0x1F			; extract request recipient bits
			select
				case RECIPIENT_DEVICE
					movf		USB_buffer_data+wValue, W, BANKED
					select
						case DEVICE_REMOTE_WAKEUP
							ifl USB_buffer_data+bRequest, EQ, CLEAR_FEATURE
								bcf			USB_device_status, 1, BANKED
							otherwise
								bsf			USB_device_status, 1, BANKED
							endi
							banksel		BD0IBC
							clrf		BD0IBC, BANKED	; set byte count to 0
							movlw		0xC8
							movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
							break
						default
							bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					ends
					break
				case RECIPIENT_ENDPOINT
					movf		USB_USWSTAT, W, BANKED
					select
						case ADDRESS_STATE
							movf		USB_buffer_data+wIndex, W, BANKED	; get EP
							andlw		0x0F			; strip off direction bit
							ifset STATUS, Z, ACCESS			; see if it is EP0
								ifl USB_buffer_data+bRequest, EQ, CLEAR_FEATURE
									bcf		UEP0, EPSTALL, ACCESS
								otherwise
									bsf		UEP0, EPSTALL, ACCESS
								endi
								banksel		BD0IBC
								clrf		BD0IBC, BANKED	; set byte count to 0
								movlw		0xC8
								movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
							otherwise
								bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
							endi
							break
						case CONFIG_STATE
							movlw		high UEP0		; put UEP0 address...
							movwf		FSR0H, ACCESS
							movlw		low UEP0
							movwf		FSR0L, ACCESS		; ...into FSR0
							movf		USB_buffer_data+wIndex, W, BANKED	; get EP
							andlw		0x0F			; strip off direction bit
							addwf		FSR0L, F, ACCESS	; add EP number to FSR0
							ifset		STATUS, C, ACCESS
								incf		FSR0H, F, ACCESS
							endi
							ifclr INDF0, EPOUTEN, ACCESS
							andifclr INDF0, EPINEN, ACCESS
								bsf			UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
							otherwise
								ifl USB_buffer_data+bRequest, EQ, CLEAR_FEATURE
									bcf		INDF0, EPSTALL, ACCESS
								otherwise
									bsf		INDF0, EPSTALL, ACCESS
								endi
								banksel		BD0IBC
								clrf		BD0IBC, BANKED	; set byte count to 0
								movlw		0xC8
								movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
							endi
							break
						default
							bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					ends
					break
				default
					bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
			ends
			break
		case SET_ADDRESS
			ifset USB_buffer_data+wValue, 7, BANKED	; if new device address is illegal, send Request Error
				bsf		UEP0, EPSTALL, ACCESS		; set EP0 protocol stall bit to signify Request Error
			otherwise
				movlw		SET_ADDRESS
				movwf		USB_dev_req, BANKED		; processing a SET_ADDRESS request
				movf		USB_buffer_data+wValue, W, BANKED
				movwf		USB_address_pending, BANKED	; save new address
				banksel		BD0IBC
				clrf		BD0IBC, BANKED			; set byte count to 0
				movlw		0xC8
				movwf		BD0IST, BANKED			; send packet as DATA1, set UOWN bit
			endi
			break
		case GET_DESCRIPTOR
			movwf		USB_dev_req, BANKED			; processing a GET_DESCRIPTOR request
			movf		USB_buffer_data+(wValue+1), W, BANKED
			select
				case DEVICE
					movlw		low (Device-Descriptor_begin)
					movwf		USB_desc_ptr, BANKED
					call		Descriptor		; get descriptor length
					movwf		USB_bytes_left, BANKED
					ifl USB_buffer_data+(wLength+1), EQ, 0
					andiff USB_buffer_data+wLength, LT, USB_bytes_left
						movf		USB_buffer_data+wLength, W, BANKED
						movwf		USB_bytes_left, BANKED
					endi
					call		SendDescriptorPacket
					break
				case CONFIGURATION
					bcf		USB_error_flags, 0, BANKED
					movf		USB_buffer_data+wValue, W, BANKED
					select
						case 0
							movlw		low (Configuration1-Descriptor_begin)
							break
						default
							bsf		USB_error_flags, 0, BANKED
					ends
					ifclr USB_error_flags, 0, BANKED
						addlw		0x02		; add offset for wTotalLength
						movwf		USB_desc_ptr, BANKED
						call		Descriptor	; get total descriptor length
						movwf		USB_bytes_left, BANKED
						movlw		0x02
						subwf		USB_desc_ptr, F, BANKED	; subtract offset for wTotalLength
						ifl USB_buffer_data+(wLength+1), EQ, 0
						andiff USB_buffer_data+wLength, LT, USB_bytes_left
							movf		USB_buffer_data+wLength, W, BANKED
							movwf		USB_bytes_left, BANKED
						endi
						call		SendDescriptorPacket
					otherwise
						bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					endi
					break
				case STRING
					bcf		USB_error_flags, 0, BANKED
					movf		USB_buffer_data+wValue, W, BANKED
					select
						case 0
							movlw		low (String0-Descriptor_begin)
							break
						case 1
							movlw		low (String1-Descriptor_begin)
							break
						case 2
							movlw		low (String2-Descriptor_begin)
							break
						default
							bsf		USB_error_flags, 0, BANKED
					ends
					ifclr USB_error_flags, 0, BANKED
						movwf		USB_desc_ptr, BANKED
						call		Descriptor	; get descriptor length
						movwf		USB_bytes_left, BANKED
						ifl USB_buffer_data+(wLength+1), EQ, 0
						andiff USB_buffer_data+wLength, LT, USB_bytes_left
							movf		USB_buffer_data+wLength, W, BANKED
							movwf		USB_bytes_left, BANKED
						endi
						call		SendDescriptorPacket
					otherwise
						bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					endi
					break
				case HID
					bcf		USB_error_flags, 0, BANKED
					movf		USB_buffer_data+wValue, W, BANKED
					select
						case 0
							movlw		low (HID1-Descriptor_begin)
							break
						default
							bsf			USB_error_flags, 0, BANKED
					ends
					ifclr USB_error_flags, 0, BANKED
						movwf		USB_desc_ptr, BANKED
						call		Descriptor	; get descriptor length
						movwf		USB_bytes_left, BANKED
						ifl USB_buffer_data+(wLength+1), EQ, 0
						andiff USB_buffer_data+wLength, LT, USB_bytes_left
							movf		USB_buffer_data+wLength, W, BANKED
							movwf		USB_bytes_left, BANKED
						endi
						call		SendDescriptorPacket
					otherwise
						bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					endi
					break
				case REPORT
					bcf		USB_error_flags, 0, BANKED
					movf		USB_buffer_data+wValue, W, BANKED
					select
						case 0
							movlw		0x3F
							movwf		USB_bytes_left, BANKED	; set descriptor length
							movlw		low (Report1-Descriptor_begin)
							break
						default
							bsf		USB_error_flags, 0, BANKED
					ends
					ifclr USB_error_flags, 0, BANKED
						movwf		USB_desc_ptr, BANKED
						ifl USB_buffer_data+(wLength+1), EQ, 0
						andiff USB_buffer_data+wLength, LT, USB_bytes_left
							movf		USB_buffer_data+wLength, W, BANKED
							movwf		USB_bytes_left, BANKED
						endi
						call		SendDescriptorPacket
					otherwise
						bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					endi
					break
				default
					bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
			ends
			break
		case GET_CONFIGURATION
			banksel		BD0IAH
			movf		BD0IAH, W, BANKED
			movwf		FSR0H, ACCESS
			movf		BD0IAL, W, BANKED
			movwf		FSR0L, ACCESS
			banksel		USB_curr_config
			movf		USB_curr_config, W, BANKED
			movwf		INDF0			; copy current device configuration to EP0 IN buffer
			banksel		BD0IBC
			movlw		0x01
			movwf		BD0IBC, BANKED		; set EP0 IN byte count to 1
			movlw		0xC8
			movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
			break
		case SET_CONFIGURATION
			ifl USB_buffer_data+wValue, LE, NUM_CONFIGURATIONS
				movf		USB_buffer_data+wValue, W, BANKED
				movwf		USB_curr_config, BANKED
				select
					case 0
						movlw		ADDRESS_STATE
						movwf		USB_USWSTAT, BANKED
#ifdef SHOW_ENUM_STATUS
						movlw		0xF0
						andwf		PORTD, F, ACCESS
						bsf		PORTD, 2, ACCESS
#endif
						break
					default
						movlw		CONFIG_STATE
						movwf		USB_USWSTAT, BANKED
						movlw		0x08
						banksel		BD1IBC
						movwf		BD1IBC, BANKED		; set EP1 IN byte count to 8 
						movlw		low (USB_Buffer+0x10)
						movwf		BD1IAL, BANKED		; set EP1 IN buffer address
						movlw		high (USB_Buffer+0x10)
						movwf		BD1IAH, BANKED
						movlw		0x48
						movwf		BD1IST, BANKED		; clear UOWN bit (PIC can write EP1 IN buffer)
						movlw		ENDPT_IN_ONLY
						movwf		UEP1, ACCESS		; enable EP1 for interrupt in transfers
#ifdef SHOW_ENUM_STATUS
						movlw		0xF0
						andwf		PORTD, F, ACCESS
						bsf		PORTD, 3, ACCESS
#endif
				ends
				banksel		BD0IBC
				clrf		BD0IBC, BANKED		; set byte count to 0
				movlw		0xC8
				movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
			otherwise
				bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
			endi
			break
		case GET_INTERFACE
			movf		USB_USWSTAT, W, BANKED
			select
				case CONFIG_STATE
					ifl USB_buffer_data+wIndex, LT, NUM_INTERFACES
						banksel		BD0IAH
						movf		BD0IAH, W, BANKED
						movwf		FSR0H, ACCESS
						movf		BD0IAL, W, BANKED	; get buffer pointer
						movwf		FSR0L, ACCESS
						clrf		INDF0		; always send back 0 for bAlternateSetting
						movlw		0x01
						movwf		BD0IBC, BANKED	; set byte count to 1
						movlw		0xC8
						movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
					otherwise
						bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					endi
					break
				default
					bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
			ends
			break
		case SET_INTERFACE
			movf		USB_USWSTAT, W, BANKED
			select
				case CONFIG_STATE
					ifl USB_buffer_data+wIndex, LT, NUM_INTERFACES
						movf		USB_buffer_data+wValue, W, BANKED
						select
							case 0	; currently support only bAlternateSetting of 0
								banksel		BD0IBC
								clrf		BD0IBC, BANKED	; set byte count to 0
								movlw		0xC8
								movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
								break
							default
								bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
						ends
					otherwise
						bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
					endi
					break
				default
					bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
			ends
			break
		case SET_DESCRIPTOR
		case SYNCH_FRAME
		default
			bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
			break
	ends
	return

ClassRequests
	movf		USB_buffer_data+bRequest, W, BANKED
	select
		case GET_REPORT
			banksel		BD0IAH
			movf		BD0IAH, W, BANKED	; put EP0 IN buffer pointer...
			movwf		FSR0H, ACCESS
			movf		BD0IAL, W, BANKED
			movwf		FSR0L, ACCESS		; ...into FSR0
			banksel		Key_buffer
			movf		Key_buffer, W, BANKED	; copy modifier byte...
			movwf		POSTINC0		; ...to EP0 IN buffer
			movf		Key_buffer+1, W, BANKED	; copy reserved byte...
			movwf		POSTINC0		; ...to EP0 IN buffer
			movf		Key_buffer+2, W, BANKED	; copy keycode 1...
			movwf		POSTINC0		; ...to EP0 IN buffer
			movf		Key_buffer+3, W, BANKED	; copy keycode 2...
			movwf		POSTINC0		; ...to EP0 IN buffer
			movf		Key_buffer+4, W, BANKED	; copy keycode 3...
			movwf		POSTINC0		; ...to EP0 IN buffer
			movf		Key_buffer+5, W, BANKED	; copy keycode 4...
			movwf		POSTINC0		; ...to EP0 IN buffer
			movf		Key_buffer+6, W, BANKED	; copy keycode 5...
			movwf		POSTINC0		; ...to EP0 IN buffer
			movf		Key_buffer+7, W, BANKED	; copy keycode 6...
			movwf		INDF0			; ...to EP0 IN buffer
			banksel		BD0IBC
			movlw		0x08
			movwf		BD0IBC, BANKED		; set EP0 IN buffer byte count to 8
			movlw		0xC8
			movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
			break
		case SET_REPORT
			movwf		USB_dev_req, BANKED	; processing a SET_REPORT request
			break
		case GET_PROTOCOL
			banksel		BD0IAH
			movf		BD0IAH, W, BANKED	; put EP0 IN buffer pointer...
			movwf		FSR0H, ACCESS
			movf		BD0IAL, W, BANKED
			movwf		FSR0L, ACCESS		; ...into FSR0
			banksel		USB_protocol
			movf		USB_protocol, W, BANKED
			movwf		INDF0
			banksel		BD0IBC
			movlw		0x01
			movwf		BD0IBC, BANKED		; set byte count to 1
			movlw		0xC8
			movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
			break
		case SET_PROTOCOL
			movf		USB_buffer_data+wValue, W, BANKED
			movwf		USB_protocol, BANKED	; update the new protocol value
			banksel		BD0IBC
			clrf		BD0IBC, BANKED		; set byte count to 0
			movlw		0xC8
			movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
			break
		case GET_IDLE
			banksel		BD0IAH
			movf		BD0IAH, W, BANKED	; put EP0 IN buffer pointer...
			movwf		FSR0H, ACCESS
			movf		BD0IAL, W, BANKED
			movwf		FSR0L, ACCESS		; ...into FSR0
			banksel		USB_idle_rate
			movf		USB_idle_rate, W, BANKED
			movwf		INDF0
			banksel		BD0IBC
			movlw		0x01
			movwf		BD0IBC, BANKED		; set byte count to 1
			movlw		0xC8
			movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
			break
		case SET_IDLE
			movf		USB_buffer_data+wValue, W, BANKED
			movwf		USB_idle_rate, BANKED	; update the new idle rate
			banksel		BD0IBC
			clrf		BD0IBC, BANKED		; set byte count to 0
			movlw		0xC8
			movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
			break
		default
			bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
	ends
	return

VendorRequests
	movf		USB_buffer_data+bRequest, W, BANKED
	select
		default
			bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
	ends
	return

ProcessInToken
	banksel		USB_USTAT
	movf		USB_USTAT, W, BANKED
	andlw		0x18		; extract the EP bits
	select
		case EP0
			movf		USB_dev_req, W, BANKED
			select
				case SET_ADDRESS
					movf		USB_address_pending, W, BANKED
					movwf		UADDR, ACCESS
					select
						case 0
							movlw		DEFAULT_STATE
							movwf		USB_USWSTAT, BANKED
#ifdef SHOW_ENUM_STATUS
							movlw		0xF0
							andwf		PORTD, F, ACCESS
							bsf			PORTD, 1, ACCESS
#endif
							break
						default
							movlw		ADDRESS_STATE
							movwf		USB_USWSTAT, BANKED
#ifdef SHOW_ENUM_STATUS
							movlw		0xF0
							andwf		PORTD, F, ACCESS
							bsf			PORTD, 2, ACCESS
#endif
					ends
					break
				case GET_DESCRIPTOR
					call		SendDescriptorPacket
					break
			ends
			break
		case EP1
			break
		case EP2
			break
	ends
	return

ProcessOutToken
	banksel		USB_USTAT
	movf		USB_USTAT, W, BANKED
	andlw		0x18		; extract the EP bits
	select
		case EP0
			movf		USB_dev_req, W, BANKED
			select
				case SET_REPORT
					movlw		NO_REQUEST
					movwf		USB_dev_req, BANKED	; clear device request
					banksel		BD0OAH
					movf		BD0OAH, W, BANKED	; put EP0 OUT buffer pointer...
					movwf		FSR0H, ACCESS
					movf		BD0OAL, W, BANKED
					movwf		FSR0L, ACCESS		; ...into FSR0
					movf		INDF0, W		; get the first byte in the buffer and...
					banksel		LED_states
					movwf		LED_states, BANKED	; ...update the LED states with it
			ends
			banksel		BD0OBC
			movlw		0x08
			movwf		BD0OBC, BANKED
			movlw		0x88
			movwf		BD0OST, BANKED
			clrf		BD0IBC, BANKED	; set byte count to 0
			movlw		0xC8
			movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
			break
		case EP1
			break
		case EP2
			break
	ends
	return

SendDescriptorPacket
	banksel		USB_bytes_left
	ifl USB_bytes_left, LT, 8
		movlw		NO_REQUEST
		movwf		USB_dev_req, BANKED	; sending a short packet, so clear device request
		movf		USB_bytes_left, W, BANKED
	otherwise
		movlw		0x08
	endi
	subwf		USB_bytes_left, F, BANKED
	movwf		USB_packet_length, BANKED
	banksel		BD0IBC
	movwf		BD0IBC, BANKED			; set EP0 IN byte count with packet size
	movf		BD0IAH, W, BANKED		; put EP0 IN buffer pointer...
	movwf		FSR0H, ACCESS
	movf		BD0IAL, W, BANKED
	movwf		FSR0L, ACCESS			; ...into FSR0
	banksel		USB_loop_index
	forlf USB_loop_index, 1, USB_packet_length
		call		Descriptor		; get next byte of descriptor being sent
		movwf		POSTINC0		; copy to EP0 IN buffer, and increment FSR0
		incf		USB_desc_ptr, F, BANKED	; increment the descriptor pointer
	next USB_loop_index
	banksel		BD0IST
	movlw		0x40
	xorwf		BD0IST, W, BANKED	; toggle the DATA01 bit
	andlw		0x40			; clear the PIDs bits
	iorlw		0x88			; set UOWN and DTS bits
	movwf		BD0IST, BANKED
	return

SendKeyBuffer
	banksel		BD1IAH
	movf		BD1IAH, W, BANKED	; put EP1 IN buffer pointer...
	movwf		FSR0H, ACCESS
	movf		BD1IAL, W, BANKED
	movwf		FSR0L, ACCESS		; ...into FSR0
	banksel		Key_buffer
	movf		Key_buffer, W, BANKED	; copy modifier byte...
	movwf		POSTINC0		; ...to EP1 IN buffer
	movf		Key_buffer+1, W, BANKED	; copy reserved byte...
	movwf		POSTINC0		; ...to EP1 IN buffer
	movf		Key_buffer+2, W, BANKED	; copy keycode 1...
	movwf		POSTINC0		; ...to EP1 IN buffer
	movf		Key_buffer+3, W, BANKED	; copy keycode 2...
	movwf		POSTINC0		; ...to EP1 IN buffer
	movf		Key_buffer+4, W, BANKED	; copy keycode 3...
	movwf		POSTINC0		; ...to EP1 IN buffer
	movf		Key_buffer+5, W, BANKED	; copy keycode 4...
	movwf		POSTINC0		; ...to EP1 IN buffer
	movf		Key_buffer+6, W, BANKED	; copy keycode 5...
	movwf		POSTINC0		; ...to EP1 IN buffer
	movf		Key_buffer+7, W, BANKED	; copy keycode 6...
	movwf		INDF0			; ...to EP1 IN buffer
	banksel		BD1IBC
	movlw		0x08
	movwf		BD1IBC, BANKED		; set EP1 IN buffer byte count to 8
	movf		BD1IST, W, BANKED	; get EP1 IN status register
	andlw		0x40			; extract the DATA01 bit
	xorlw		0x40			; toggle the DATA01 bit
	iorlw		0x88			; set UOWN and DTS bits
	movwf		BD1IST, BANKED		; send packet
	return

WaitConfiguredUSB

	repeat
		call		ServiceUSB	; service USB requests...
		banksel		PORTA
		btg		PORTA, 1, ACCESS
		banksel		USB_USWSTAT
	until USB_USWSTAT, EQ, CONFIG_STATE	; ...until the host configures the peripheral
	banksel		LED_states
	clrf		LED_states, BANKED
	clrf		Key_buffer, BANKED
	clrf		Key_buffer+1, BANKED
	clrf		Key_buffer+2, BANKED
	clrf		Key_buffer+3, BANKED
	clrf		Key_buffer+4, BANKED
	clrf		Key_buffer+5, BANKED
	clrf		Key_buffer+6, BANKED
	clrf		Key_buffer+7, BANKED
	return

			END
