;**************************************************************
; usb routines
; firmware for the built in usb device

;**************************************************************
; includes
#include <p18f2550.inc>
#include "usb_defs.inc"
#include "tableread.inc"
#include "ENGR2210.inc"

;**************************************************************
; exported subroutines
	global	InitUSB
	global	ServiceUSB
	global	WaitConfiguredUSB

;**************************************************************
; exported variables
	global	LED_states

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
LED_states		RES	5

;**************************************************************
; code section
usb_code		CODE	0x00082a

Descriptor
	tableread	Descriptor_begin, USB_desc_ptr
	return

Descriptor_begin
Device
db	0x12, DEVICE			; bLength, bDescriptorType
db	0x10, 0x01			; bcdUSB (low byte), bcdUSB (high byte)
db	0x00, 0x00			; bDeviceClass, bDeviceSubClass
db	0x00, 0x08			; bDeviceProtocl, bMaxPacketSize
db	0xD8, 0x04			; idVendor (low byte), idVendor (high byte)
db	0x0C, 0xff			; idProduct (low byte), idProduct (high byte)
db	0x01, 0x00			; bcdDevice (low byte), bcdDevice (high byte)
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
db	0x03, 0x00		; bInterfaceClass (HID code), bInterfaceSubClass (no subclass)
db	0x00, 0x00		; bInterfaceProtocol (none), iInterface (none)
HID1
db	0x09, HID			; bLength, bDescriptorType
db	0x00, 0x01			; bcdHID (low byte), bcdHID (high byte)
db	0x00, 0x01			; bCountryCode (none), bNumDescriptors


;db	REPORT, String0 - Report1	; bDescriptorType, wDescriptorLength (low byte)
#define REPORT_DESCRIPTOR_LENGTH	0x53
db	REPORT, REPORT_DESCRIPTOR_LENGTH; hard coded length because of padding
db	0x00, 0x07			; wDescriptorLength (high byte), bLength (Endpoint1 descriptor starts here)
db	ENDPOINT, 0x81			; bDescriptorType, bEndpointAddress (EP1 IN)
db	0x03, 0x08			; bmAttributes (Interrupt), wMaxPacketSize (low byte)
db	0x00, 0x0A			; wMaxPacketSize (high byte), bInterval (10 ms)

oneLedUsage	macro	usageType
db	0x05, 0x08			; Usage Page (LEDs),
db	0x09, usageType			; Usage (usageType),
db	0x91, 0x02			; Output (Data, Variable, Absolute),  ; LED report
db	0x95, 0x01			; Report Count (1),
db	0x75, 0x08			; Report Size (8),
db	0x15, 0x00			; Logical Minimum (0),
db	0x25, 0x01			; Logical Maximum (1),
		endm

Report1
db	0x05, 0x0C			; Usage Page (Consumer),
db	0x09, 0x01			; Usage (Consumer specific),
db	0xA1, 0x01			; Collection (Application),
	oneLedUsage	0x48		; red LED
	oneLedUsage	0x4a		; amber LED (in fact it is yellow)
	oneLedUsage	0x49		; green LED
	oneLedUsage	0x4b		; generic indicator (blue LED)
	oneLedUsage	0x4b		; generic indicator (white LED)
db	0x91, 0x01			; Output(Constant) padding
db	0x95, 0x03			; Report Count (3) -> pad total report to 8 bytes
db	0x75, 0x08			; Report Size (8)
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
db	'X', 0x00			; bString
db	'F', 0x00
db	'D', 0x00
db	'e', 0x00
db	'v', 0x00
db	'i', 0x00
db	'c', 0x00
db	'e', 0x00
db	' ', 0x00
db	'P', 0x00
db	'I', 0x00
db	'C', 0x00
db	'1', 0x00
db	'8', 0x00
db	'F', 0x00
db	'2', 0x00
db	'5', 0x00
db	'5', 0x00
db	'0', 0x00
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
	return

ServiceUSB
	select
		caseset	UIR, UERRIF, ACCESS
			clrf		UEIR, ACCESS
			break
		caseset UIR, SOFIF, ACCESS
			bcf		UIR, SOFIF, ACCESS
			break
		caseset	UIR, IDLEIF, ACCESS
			bcf		UIR, IDLEIF, ACCESS
			break
		caseset UIR, ACTVIF, ACCESS
			bcf		UIR, ACTVIF, ACCESS
			bcf		UCON, SUSPND, ACCESS
			break
		caseset	UIR, STALLIF, ACCESS
			bcf		UIR, STALLIF, ACCESS
			break
		caseset	UIR, URSTIF, ACCESS
			call resetUSB
			break
		caseset	UIR, TRNIF, ACCESS
			; a USB transaction is complete
			call processUSBTransaction
			break
	ends
	return

resetUSB
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
	return

	; dispatch request codes to specific labels
dispatchRequest	macro	requestCode, requestLabel
	xorlw	requestCode
	btfsc	STATUS,Z,ACCESS
	goto	requestLabel
	xorlw	requestCode
	endm
	

processUSBTransaction
	movlw		0x04
	movwf		FSR0H, ACCESS
	movf		USTAT, W, ACCESS
	andlw		0x7C				; mask out bits 0, 1, and 7 of USTAT
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
	bcf		UIR, TRNIF, ACCESS		; clear TRNIF interrupt flag
	movf		USB_buffer_desc, W, BANKED
	andlw		0x3C				; extract PID bits
	dispatchRequest	TOKEN_SETUP, processSetupToken
	dispatchRequest	TOKEN_IN, processInToken
	dispatchRequest	TOKEN_OUT, processOutToken
	return

processSetupToken
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
	ifl	USB_buffer_data+bmRequestType, 0x21
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
			call		standardRequests
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

standardRequests
	movf	USB_buffer_data+bRequest, W, BANKED

	dispatchRequest	GET_STATUS, getStatusRequest
	dispatchRequest	CLEAR_FEATURE, setFeatureRequest
	dispatchRequest	SET_FEATURE, setFeatureRequest
	dispatchRequest	SET_ADDRESS, setAddressRequest
	dispatchRequest	GET_DESCRIPTOR, getDescriptorRequest
	dispatchRequest	GET_CONFIGURATION, getConfigurationRequest
	dispatchRequest	SET_CONFIGURATION, setConfigurationRequest
	dispatchRequest	GET_INTERFACE, getInterfaceRequest
	dispatchRequest	SET_INTERFACE, setInterfaceRequest

standardRequestsError
	bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
	return

setInterfaceRequest
	movf		USB_USWSTAT, W, BANKED
	select
		case CONFIG_STATE
			movlw	NUM_INTERFACES
			subwf	USB_buffer_data+wIndex,W,BANKED
			btfsc	STATUS,C,ACCESS
			goto	standardRequestsError	; USB_buffer_data+wIndex < NUM_INTERFACES
				movf		USB_buffer_data+wValue, W, BANKED
			select
				case 0	; currently support only bAlternateSetting of 0
					banksel		BD0IBC
					clrf		BD0IBC, BANKED	; set byte count to 0
					movlw		0xC8
					movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
					break
				default
					goto	standardRequestsError
			ends
			break
		default
			goto	standardRequestsError
	ends
	return

getInterfaceRequest
	movf		USB_USWSTAT, W, BANKED
	select
		case CONFIG_STATE
			movlw	NUM_INTERFACES
			subwf	USB_buffer_data+wIndex,W,BANKED
			btfsc	STATUS,C,ACCESS
			goto	standardRequestsError	; USB_buffer_data+wIndex < NUM_INTERFACES
			banksel	BD0IAH
			movf	BD0IAH, W, BANKED
			movwf	FSR0H, ACCESS
			movf	BD0IAL, W, BANKED	; get buffer pointer
			movwf	FSR0L, ACCESS
			clrf	INDF0		; always send back 0 for bAlternateSetting
			movlw	0x01
			movwf	BD0IBC, BANKED	; set byte count to 1
			movlw	0xC8
			movwf	BD0IST, BANKED	; send packet as DATA1, set UOWN bit
			break
		default
			goto	standardRequestsError
	ends
	return

setConfigurationRequest
	movf	USB_buffer_data+wValue,W,BANKED
	sublw	NUM_CONFIGURATIONS
	btfss	STATUS,C,ACCESS
	goto	standardRequestsError	; USB_buffer_data+wValue > NUM_CONFIGURATIONS
	movf	USB_buffer_data+wValue, W, BANKED
	movwf	USB_curr_config, BANKED
	select
		case 0
			movlw		ADDRESS_STATE
			movwf		USB_USWSTAT, BANKED
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
			movwf		BD1IST, BANKED	; clear UOWN bit (PIC can write EP1 IN buffer)
			movlw		ENDPT_IN_ONLY
			movwf		UEP1, ACCESS	; enable EP1 for interrupt in transfers
	ends
	banksel		BD0IBC
	clrf		BD0IBC, BANKED		; set byte count to 0
	movlw		0xC8
	movwf		BD0IST, BANKED		; send packet as DATA1, set UOWN bit
	return

getConfigurationRequest
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
	return

setAddressRequest
	ifset USB_buffer_data+wValue, 7, BANKED	; if new device address is illegal, send Request Error
		goto		standardRequestsError
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
	return

getStatusRequest
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
					goto	standardRequestsError
					break
				case CONFIG_STATE
					movlw	NUM_INTERFACES
					subwf	USB_buffer_data+wIndex,W,BANKED
					btfsc	STATUS,C,ACCESS
					goto	standardRequestsError	; USB_buffer_data+wIndex < NUM_INTERFACES
					banksel	BD0IAH
					movf	BD0IAH, W, BANKED
					movwf	FSR0H, ACCESS
					movf	BD0IAL, W, BANKED	; get buffer pointer
					movwf	FSR0L, ACCESS
					clrf	POSTINC0
					clrf	INDF0
					movlw	0x02
					movwf	BD0IBC, BANKED		; set byte count to 2
					movlw	0xC8
					movwf	BD0IST, BANKED	; send packet as DATA1, set UOWN bit
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
						goto	standardRequestsError
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
						goto	standardRequestsError
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
					goto	standardRequestsError
			ends
			break
		default
			goto	standardRequestsError
	ends
	return

setFeatureRequest
	movf		USB_buffer_data+bmRequestType, W, BANKED
	andlw		0x1F			; extract request recipient bits
	select
		case RECIPIENT_DEVICE
			movf		USB_buffer_data+wValue, W, BANKED
			select
				case DEVICE_REMOTE_WAKEUP
					ifl USB_buffer_data+bRequest, CLEAR_FEATURE
						bcf		USB_device_status, 1, BANKED
					otherwise
						bsf		USB_device_status, 1, BANKED
					endi
					banksel		BD0IBC
					clrf		BD0IBC, BANKED	; set byte count to 0
					movlw		0xC8
					movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
					break
				default
					goto		standardRequestsError
			ends
			break
		case RECIPIENT_ENDPOINT
			movf		USB_USWSTAT, W, BANKED
			select
				case ADDRESS_STATE
					movf		USB_buffer_data+wIndex, W, BANKED	; get EP
					andlw		0x0F			; strip off direction bit
					ifset STATUS, Z, ACCESS			; see if it is EP0
						ifl USB_buffer_data+bRequest, CLEAR_FEATURE
							bcf		UEP0, EPSTALL, ACCESS
						otherwise
							bsf		UEP0, EPSTALL, ACCESS
						endi
						banksel		BD0IBC
						clrf		BD0IBC, BANKED	; set byte count to 0
						movlw		0xC8
						movwf		BD0IST, BANKED	; send packet as DATA1, set UOWN bit
					otherwise
						goto		standardRequestsError
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
						goto		standardRequestsError
					otherwise
						ifl USB_buffer_data+bRequest, CLEAR_FEATURE
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
					goto		standardRequestsError
			ends
			break
		default
			goto		standardRequestsError
	ends
	return

getDescriptorRequest
	movlw		GET_DESCRIPTOR
	movwf		USB_dev_req, BANKED			; processing a GET_DESCRIPTOR request
	movf		USB_buffer_data+(wValue+1), W, BANKED
	select
		case DEVICE
			movlw		low (Device-Descriptor_begin)
			movwf		USB_desc_ptr, BANKED
			call		Descriptor		; get descriptor length
			movwf		USB_bytes_left, BANKED
			ifl USB_buffer_data+(wLength+1), 0
			andiffLT USB_buffer_data+wLength, USB_bytes_left
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
				ifl USB_buffer_data+(wLength+1), 0
				andiffLT USB_buffer_data+wLength, USB_bytes_left
					movf		USB_buffer_data+wLength, W, BANKED
					movwf		USB_bytes_left, BANKED
				endi
				call		SendDescriptorPacket
			otherwise
				goto		standardRequestsError
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
				ifl USB_buffer_data+(wLength+1), 0
				andiffLT USB_buffer_data+wLength, USB_bytes_left
					movf		USB_buffer_data+wLength, W, BANKED
					movwf		USB_bytes_left, BANKED
				endi
				call		SendDescriptorPacket
			otherwise
				goto		standardRequestsError
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
			ifl USB_buffer_data+(wLength+1), 0
				andiffLT USB_buffer_data+wLength, USB_bytes_left
					movf		USB_buffer_data+wLength, W, BANKED
					movwf		USB_bytes_left, BANKED
				endi
				call		SendDescriptorPacket
			otherwise
				goto		standardRequestsError
			endi
			break
		case REPORT
			bcf		USB_error_flags, 0, BANKED
			movf		USB_buffer_data+wValue, W, BANKED
			select
				case 0
					movlw		REPORT_DESCRIPTOR_LENGTH
					movwf		USB_bytes_left, BANKED	; set descriptor length
					movlw		low (Report1-Descriptor_begin)
					break
				default
					bsf		USB_error_flags, 0, BANKED
			ends
			ifclr USB_error_flags, 0, BANKED
				movwf		USB_desc_ptr, BANKED
				ifl USB_buffer_data+(wLength+1), 0
				andiffLT USB_buffer_data+wLength, USB_bytes_left
					movf		USB_buffer_data+wLength, W, BANKED
					movwf		USB_bytes_left, BANKED
				endi
				call		SendDescriptorPacket
			otherwise
				goto		standardRequestsError
			endi
			break
		default
			goto		standardRequestsError
	ends
	return

ClassRequests
	movf		USB_buffer_data+bRequest, W, BANKED
	select
		case GET_REPORT
			; report current LED_state
			banksel		BD0IAH
			movf		BD0IAH, W, BANKED	; put EP0 IN buffer pointer...
			movwf		FSR0H, ACCESS
			movf		BD0IAL, W, BANKED
			movwf		FSR0L, ACCESS		; ...into FSR0
			banksel 	LED_states
			movf		LED_states, W, BANKED	; red led
			movwf		POSTINC0
			movf		LED_states+1, W, BANKED	; yellow led
			movwf		POSTINC0
			movf		LED_states+2, W, BANKED	; green led
			movwf		POSTINC0
			movf		LED_states+3, W, BANKED	; blue led
			movwf		POSTINC0
			movf		LED_states+4, W, BANKED	; white led
			movwf		INDF0			; ...to EP0 IN buffer
			banksel		BD0IBC
			movlw		0x05
			movwf		BD0IBC, BANKED		; set EP0 IN buffer byte count
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

processInToken
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
							break
						default
							movlw		ADDRESS_STATE
							movwf		USB_USWSTAT, BANKED
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

processOutToken
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
				; get five bytes in the buffer and copy to LED_states
					banksel		LED_states
					movf		POSTINC0, W	
					movwf		LED_states, BANKED
					movf		POSTINC0, W	
					movwf		LED_states+1, BANKED
					movf		POSTINC0, W	
					movwf		LED_states+2, BANKED
					movf		POSTINC0, W	
					movwf		LED_states+3, BANKED
					movf		INDF0, W	
					movwf		LED_states+4, BANKED
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
	
	movlw		0x08
	subwf		USB_bytes_left,W,BANKED
	btfsc		STATUS,C,ACCESS
	goto		longDescriptor		; bytes_left > 8

	movlw		NO_REQUEST
	movwf		USB_dev_req, BANKED	; sending a short packet, so clear device request
	movf		USB_bytes_left, W, BANKED
	goto		shortDescriptor

longDescriptor
	movlw		0x08

shortDescriptor
	; bytes to send now in W
	subwf		USB_bytes_left, F, BANKED
	movwf		USB_packet_length, BANKED
	banksel		BD0IBC
	movwf		BD0IBC, BANKED			; set EP0 IN byte count with packet size
	movf		BD0IAH, W, BANKED		; put EP0 IN buffer pointer...
	movwf		FSR0H, ACCESS
	movf		BD0IAL, W, BANKED
	movwf		FSR0L, ACCESS			; ...into FSR0
	banksel		USB_loop_index

	movlw		1
	movwf		USB_loop_index,BANKED
sendNextDescriptorByte
	movf		USB_loop_index,W,BANKED
	subwf		USB_packet_length,W,BANKED
	btfss		STATUS,C,ACCESS
	goto		descriptorSent

	call		Descriptor		; get next byte of descriptor being sent
	movwf		POSTINC0		; copy to EP0 IN buffer, and increment FSR0
	incf		USB_desc_ptr, F, BANKED	; increment the descriptor pointer

	incf		USB_loop_index,F,BANKED
	goto		sendNextDescriptorByte
descriptorSent

	banksel		BD0IST
	movlw		0x40
	xorwf		BD0IST, W, BANKED	; toggle the DATA01 bit
	andlw		0x40			; clear the PIDs bits
	iorlw		0x88			; set UOWN and DTS bits
	movwf		BD0IST, BANKED
	return

WaitConfiguredUSB
	call	ServiceUSB		; service USB requests...
	banksel	USB_USWSTAT
	movf	USB_USWSTAT,W,BANKED
	sublw	CONFIG_STATE
	btfss	STATUS,Z,ACCESS
	goto	WaitConfiguredUSB	; ...until the host configures the peripheral

	banksel		LED_states
	clrf		LED_states, BANKED
	return

			END
