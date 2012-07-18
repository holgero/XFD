;**************************************************************
; usb routines
; firmware for the built in usb device

;**************************************************************
; includes
#include <p18f2550.inc>

;**************************************************************
; exported subroutines
	global	InitUSB
	global	ServiceUSB
	global	WaitConfiguredUSB

;**************************************************************
; exported variables
	global	LED_states
	global	USB_received

;**************************************************************
; local definitions
NUM_CONFIGURATIONS	EQU	1
NUM_INTERFACES		EQU	1
; usb states
POWERED_STATE		EQU	0x00
DEFAULT_STATE		EQU	0x01
ADDRESS_STATE		EQU	0x02
CONFIG_STATE		EQU	0x03

; endpoint types
ENDPT_IN		EQU	0x12
ENDPT_OUT		EQU	0x14
ENDPT_CONTROL		EQU	0x16

; tokens
TOKEN_OUT		EQU	(0x01<<2)
TOKEN_IN		EQU	(0x09<<2)
TOKEN_SETUP		EQU	(0x0D<<2)

; usb addresses
BDOST			EQU	0x0400
BDOBC			EQU	0x0401
BDOAL			EQU	0x0402
BDOAH			EQU	0x0403
BDIST			EQU	0x0404
BDIBC			EQU	0x0405
BDIAL			EQU	0x0406
BDIAH			EQU	0x0407
; Register location after last buffer descriptor register
USB_Buffer		EQU	0x0480

; offsets from the beginning of the Buffer Descriptor
ADDRESSL		EQU	0x02
ADDRESSH		EQU	0x03

; descriptor types
DEVICE			EQU	1
CONFIGURATION		EQU	2
STRING			EQU	3
INTERFACE		EQU	4
ENDPOINT		EQU	5

; HID descriptor types
HID			EQU	0x21
REPORT			EQU	0x22
PHYSICAL		EQU	0x23

; offsets into the setup data record
bmRequestType		EQU	0x00
bRequest		EQU	0x01
wValue			EQU	0x02
wIndex			EQU	0x04
wLength			EQU	0x06

; USB requests
NO_REQUEST		EQU	0xFF
GET_STATUS		EQU	0x00
CLEAR_FEATURE		EQU	0x01
SET_FEATURE		EQU	0x03
SET_ADDRESS		EQU	0x05
GET_DESCRIPTOR		EQU	0x06
SET_DESCRIPTOR		EQU	0x07
GET_CONFIGURATION	EQU	0x08
SET_CONFIGURATION	EQU	0x09
GET_INTERFACE		EQU	0x0A
SET_INTERFACE		EQU	0x0B

; HID Class requests
GET_REPORT		EQU	0x01
GET_IDLE		EQU	0x02
GET_PROTOCOL		EQU	0x03
SET_REPORT		EQU	0x09
SET_IDLE		EQU	0x0A
SET_PROTOCOL		EQU	0x0B
HID_SET_REPORT		EQU	0x21

; endpoints
EP0			EQU	0x00 << 3
EP1			EQU	0x01 << 3
EP2			EQU	0x02 << 3

; request targets
STANDARD		EQU	0x00 << 5
CLASS			EQU	0x01 << 5
VENDOR			EQU	0x02 << 5

RECIPIENT_DEVICE	EQU	0x00
RECIPIENT_INTERFACE	EQU	0x01
RECIPIENT_ENDPOINT	EQU	0x02

; request codes
WAKEUP_REQUEST		EQU	0x01
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
USB_received		RES	1
LED_states		RES	5

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
	btfss		STATUS, C, ACCESS
	goto		decriptorAddressCalculated
	incfsz		TBLPTRH, F, ACCESS
	goto		decriptorAddressCalculated
	incf		TBLPTRU, F, ACCESS
decriptorAddressCalculated
	movwf		TBLPTRL, ACCESS
	tblrd*
	movf		TABLAT, W, ACCESS
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

StringOffsetsTable
db	String0 - Descriptor_begin, String1 - Descriptor_begin
db	String2 - Descriptor_begin

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
	btfsc	UIR, UERRIF, ACCESS
	clrf		UEIR, ACCESS
	btfsc	UIR, SOFIF, ACCESS
	bcf		UIR, SOFIF, ACCESS
	btfsc	UIR, IDLEIF, ACCESS
	bcf		UIR, IDLEIF, ACCESS
	btfss	UIR, ACTVIF, ACCESS
	goto	serviceUsbActvifNotSet
	bcf		UIR, ACTVIF, ACCESS
	bcf		UCON, SUSPND, ACCESS
serviceUsbActvifNotSet
	btfsc	UIR, STALLIF, ACCESS
	bcf		UIR, STALLIF, ACCESS
	btfsc	UIR, URSTIF, ACCESS
	goto	resetUSB
	btfsc	UIR, TRNIF, ACCESS		; no USB transaction complete
	goto	processUSBTransaction
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
	banksel		BDOBC
	movlw		0x08
	movwf		BDOBC, BANKED
	movlw		low USB_Buffer		; EP0 OUT gets a buffer...
	movwf		BDOAL, BANKED
	movlw		high USB_Buffer
	movwf		BDOAH, BANKED		; ...set up its address
	movlw		0x88			; set UOWN bit (USB can write)
	movwf		BDOST, BANKED
	movlw		low (USB_Buffer+0x08)	; EP0 IN gets a buffer...
	movwf		BDIAL, BANKED
	movlw		high (USB_Buffer+0x08)
	movwf		BDIAH, BANKED		; ...set up its address
	movlw		0x08			; clear UOWN bit (MCU can write)
	movwf		BDIST, BANKED
	clrf		UADDR, ACCESS		; set USB Address to 0
	clrf		UIR, ACCESS		; clear all the USB interrupt flags
	movlw		ENDPT_CONTROL
	movwf		UEP0, ACCESS		; EP0 is a control pipe and requires an ACK
	movlw		0xFF			; enable all error interrupts
	movwf		UEIE, ACCESS
	banksel		USB_USWSTAT
	movlw		DEFAULT_STATE
	movwf		USB_USWSTAT, BANKED
	movlw		0x01
	movwf		USB_device_status, BANKED ; self powered, remote wakeup disabled
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
	banksel		BDOBC
	movlw		0x08
	movwf		BDOBC, BANKED		; reset the byte count
	movwf		BDIST, BANKED		; return the in buffer to us (dequeue any pending requests)
	banksel		USB_buffer_data+bmRequestType
	movf		USB_buffer_data+bmRequestType,W,BANKED
	sublw		HID_SET_REPORT
	btfss		STATUS,Z,ACCESS		; skip if request type is HID_SET_REPORT
	goto		setupTokenOtherRequestTypes
	movlw		0xC8
	goto		setupTokenAllRequestTypes
setupTokenOtherRequestTypes
	movlw		0x88
setupTokenAllRequestTypes
	banksel		BDOST
	movwf		BDOST, BANKED	; set EP0 OUT UOWN back to USB and DATA0/DATA1 packet according to request type
	bcf		UCON, PKTDIS, ACCESS	; assuming there is nothing to dequeue, clear the packet disable bit
	banksel		USB_dev_req
	movlw		NO_REQUEST
	movwf		USB_dev_req, BANKED			; clear the device request in process
	movf		USB_buffer_data+bmRequestType, W, BANKED
	andlw		0x60					; extract request type bits
	dispatchRequest	STANDARD, standardRequests
	dispatchRequest	CLASS, classRequests
	dispatchRequest	VENDOR, vendorRequests
	goto		standardRequestsError

standardRequests
	movf		USB_buffer_data+bRequest, W, BANKED
	dispatchRequest	GET_STATUS, getStatusRequest
	dispatchRequest	CLEAR_FEATURE, setFeatureRequest
	dispatchRequest	SET_FEATURE, setFeatureRequest
	dispatchRequest	SET_ADDRESS, setAddressRequest
	dispatchRequest	GET_DESCRIPTOR, getDescriptorRequest
	dispatchRequest	GET_CONFIGURATION, getConfigurationRequest
	dispatchRequest	SET_CONFIGURATION, setConfigurationRequest
	dispatchRequest	GET_INTERFACE, getInterfaceRequest
	dispatchRequest	SET_INTERFACE, setInterfaceRequest

vendorRequests
standardRequestsError
	bsf		UEP0, EPSTALL, ACCESS	; set EP0 protocol stall bit to signify Request Error
	return

sendAnswerOk
	banksel		BDIBC
	clrf		BDIBC, BANKED	; set byte count to 0
sendAnswer
	movlw		0xC8
	movwf		BDIST, BANKED	; send packet as DATA1, set UOWN bit
	return

gotoRequestErrorIfNotConfigured	macro
	movf	USB_USWSTAT, W, BANKED
	sublw	CONFIG_STATE		; are we configured?
	btfss	STATUS,Z,ACCESS		; skip if yes
	goto	standardRequestsError	; not yet configured
	endm
	
setInterfaceRequest
	gotoRequestErrorIfNotConfigured

	movlw	NUM_INTERFACES
	subwf	USB_buffer_data+wIndex,W,BANKED
	btfsc	STATUS,C,ACCESS
	goto	standardRequestsError	; USB_buffer_data+wIndex < NUM_INTERFACES
	movf	USB_buffer_data+wValue, W, BANKED
	; bAlternateSetting needs to be 0
	btfss	STATUS,Z,ACCESS		; skip if zero
	goto	standardRequestsError	; not zero
	goto	sendAnswerOk	; ok

getInterfaceRequest
	gotoRequestErrorIfNotConfigured

	movlw	NUM_INTERFACES
	subwf	USB_buffer_data+wIndex,W,BANKED
	btfsc	STATUS,C,ACCESS
	goto	standardRequestsError	; USB_buffer_data+wIndex < NUM_INTERFACES
	banksel	BDIAH
	movf	BDIAH, W, BANKED
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED	; get buffer pointer
	movwf	FSR0L, ACCESS
	clrf	INDF0		; always send back 0 for bAlternateSetting
	movlw	0x01
	movwf	BDIBC, BANKED	; set byte count to 1
	goto	sendAnswer

setConfigurationRequest
	movf	USB_buffer_data+wValue,W,BANKED
	sublw	NUM_CONFIGURATIONS
	btfss	STATUS,C,ACCESS
	goto	standardRequestsError	; USB_buffer_data+wValue > NUM_CONFIGURATIONS
	movf	USB_buffer_data+wValue, W, BANKED
	movwf	USB_curr_config, BANKED
	btfss	STATUS,Z,ACCESS		; skip if value is zero
	goto	setConfiguredState
	; set address state
	movlw	ADDRESS_STATE
	movwf	USB_USWSTAT, BANKED
	goto	sendAnswerOk
setConfiguredState
	; we know we have only one configuration, set it up
	movlw	CONFIG_STATE
	movwf	USB_USWSTAT, BANKED
	movlw	0x08
	banksel	BDIBC+0x08
	movwf	BDIBC+0x08, BANKED	; set EP1 IN byte count to 8 
	movlw	low (USB_Buffer+0x10)
	movwf	BDIAL+0x08, BANKED	; set EP1 IN buffer address
	movlw	high (USB_Buffer+0x10)
	movwf	BDIAH+0x08, BANKED
	movlw	0x48
	movwf	BDIST+0x08, BANKED	; clear UOWN bit (PIC can write EP1 IN buffer)
	movlw	ENDPT_IN
	movwf	UEP1, ACCESS		; enable EP1 for interrupt in transfers
	goto	sendAnswerOk

getConfigurationRequest
	banksel	BDIAH
	movf	BDIAH, W, BANKED
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED
	movwf	FSR0L, ACCESS
	banksel	USB_curr_config
	movf	USB_curr_config, W, BANKED
	movwf	INDF0			; copy current device configuration to EP0 IN buffer
	banksel	BDIBC
	movlw	0x01
	movwf	BDIBC, BANKED		; set EP0 IN byte count to 1
	goto	sendAnswer

setAddressRequest
	btfsc	USB_buffer_data+wValue, 7, BANKED 
	goto	standardRequestsError	; new device address illegal
	movlw	SET_ADDRESS
	movwf	USB_dev_req, BANKED	; processing a SET_ADDRESS request
	movf	USB_buffer_data+wValue, W, BANKED
	movwf	USB_address_pending, BANKED	; save new address
	goto	sendAnswerOk

getStatusRequest
	movf	USB_buffer_data+bmRequestType, W, BANKED
	andlw	0x1F			; extract request recipient bits
	dispatchRequest	RECIPIENT_DEVICE, getDeviceStatusRequest
	dispatchRequest	RECIPIENT_INTERFACE, getInterfaceStatusRequest
	dispatchRequest RECIPIENT_ENDPOINT, getEndpointStatusRequest
	goto	standardRequestsError

getDeviceStatusRequest
	banksel	BDIAH
	movf	BDIAH, W, BANKED
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED	; get buffer pointer
	movwf	FSR0L, ACCESS
	banksel	USB_device_status
	; copy device status byte to EP0 buffer
	movf	USB_device_status, W, BANKED	
	movwf	POSTINC0
	clrf	INDF0
	banksel	BDIBC
	movlw	0x02
	movwf	BDIBC, BANKED		; set byte count to 2
	goto	sendAnswer

getInterfaceStatusRequest
	gotoRequestErrorIfNotConfigured
	movlw	NUM_INTERFACES
	subwf	USB_buffer_data+wIndex,W,BANKED
	btfsc	STATUS,C,ACCESS
	goto	standardRequestsError	; USB_buffer_data+wIndex < NUM_INTERFACES
	banksel	BDIAH
	movf	BDIAH, W, BANKED
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED	; get buffer pointer
	movwf	FSR0L, ACCESS
	clrf	POSTINC0
	clrf	INDF0
	movlw	0x02
	movwf	BDIBC, BANKED		; set byte count to 2
	goto	sendAnswer

getEndpointStatusRequest
	movf	USB_USWSTAT, W, BANKED
	dispatchRequest	ADDRESS_STATE, getEndpointStatusInAddressStateRequest
	dispatchRequest	CONFIG_STATE, getEndpointStatusInConfiguredStateRequest
	goto	standardRequestsError

getEndpointStatusInAddressStateRequest
	movf	USB_buffer_data+wIndex, W, BANKED	; get EP
	andlw	0x0F			; strip off direction bit
	btfss	STATUS,Z,ACCESS		; is it EP0?
	goto	standardRequestsError	; not zero
	banksel	BDIAH
	movf	BDIAH, W, BANKED	; put EP0 IN buffer ptr
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED
	movwf	FSR0L, ACCESS		; ...into FSR0
	movlw	0x00
	btfsc	UEP0, EPSTALL, ACCESS
	movlw	0x01
	movwf	POSTINC0
	clrf	INDF0
	movlw	0x02
	movwf	BDIBC, BANKED		; set byte count to 2
	goto	sendAnswer

getEndpointStatusInConfiguredStateRequest
	banksel	BDIAH
	movf	BDIAH, W, BANKED	; put EP0 IN buffer pointer...
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED
	movwf	FSR0L, ACCESS		; ...into FSR0
	movlw	high UEP0		; put UEP0 address...
	movwf	FSR1H, ACCESS
	movlw	low UEP0
	movwf	FSR1L, ACCESS		; ...into FSR1
	banksel	USB_buffer_data+wIndex
	movf	USB_buffer_data+wIndex, W, BANKED  ; get EP and...
	andlw	0x0F			; ...strip off direction bit
	btfsc	PLUSW1, EPOUTEN, ACCESS
	goto	okToReply
	btfss	PLUSW1, EPINEN, ACCESS
	goto	standardRequestsError	; neither EPOUTEN nor EPINEN are set
okToReply
	; send back the state of the EPSTALL bit + 0 byte
	movlw	0x01
	btfss	PLUSW1, EPSTALL, ACCESS
	clrw
	movwf	POSTINC0
	clrf	INDF0
	banksel	BDIBC
	movlw	0x02
	movwf	BDIBC, BANKED		; set byte count to 2
	goto	sendAnswer

setFeatureRequest
	movf	USB_buffer_data+bmRequestType, W, BANKED
	andlw	0x1F				; extract request recipient bits
	dispatchRequest	RECIPIENT_DEVICE, setDeviceFeatureRequest
	dispatchRequest	RECIPIENT_ENDPOINT, setEndpointFeatureRequest
	goto	standardRequestsError

setDeviceFeatureRequest
	movf	USB_buffer_data+wValue, W, BANKED
	sublw	WAKEUP_REQUEST
	btfss	STATUS, Z, ACCESS	; skip if request is wakeup
	goto	standardRequestsError	; dunno what to do with this request
	bcf	USB_device_status, 1, BANKED
	movf	USB_buffer_data+bRequest, W, BANKED
	sublw	CLEAR_FEATURE
	btfss	STATUS, Z		; skip if == CLEAR_FEATURE
	bsf	USB_device_status, 1, BANKED
	goto	sendAnswerOk

setEndpointFeatureRequest
	movf		USB_USWSTAT, W, BANKED
	dispatchRequest	ADDRESS_STATE, setEndpointFeatureInAddressStateRequest
	dispatchRequest	CONFIG_STATE, setEndpointFeatureInConfiguredStateRequest
	goto	standardRequestsError

setEndpointFeatureInAddressStateRequest
	movf	USB_buffer_data+wIndex, W, BANKED ; get EP
	andlw	0x0F			; strip off direction bit
	btfss	STATUS,Z,ACCESS		; is it EP0?
	goto	standardRequestsError	; not zero
	bcf	UEP0, EPSTALL, ACCESS
	movf	USB_buffer_data+bRequest, W, BANKED
	sublw	CLEAR_FEATURE
	btfss	STATUS, Z		; skip if == CLEAR_FEATURE
	bsf	UEP0, EPSTALL, ACCESS
	goto	sendAnswerOk

setEndpointFeatureInConfiguredStateRequest
	movlw	high UEP0		; put UEP0 address...
	movwf	FSR0H, ACCESS
	movlw	low UEP0
	movwf	FSR0L, ACCESS		; ...into FSR0
	movf	USB_buffer_data+wIndex, W, BANKED	; get EP
	andlw	0x0F			; strip off direction bit
	addwf	FSR0L, F, ACCESS	; add EP number to FSR0
	btfsc	STATUS, C, ACCESS
	incf	FSR0H, F, ACCESS
	btfsc	INDF0, EPOUTEN, ACCESS
	goto	continueAnswerConfigState
	btfss	INDF0, EPINEN, ACCESS
	goto	standardRequestsError	; neither EPOUTEN nor EPINEN are set: error
continueAnswerConfigState
	bcf	INDF0, EPSTALL, ACCESS
	movf	USB_buffer_data+bRequest, W, BANKED
	sublw	CLEAR_FEATURE
	btfss	STATUS, Z		; skip if == CLEAR_FEATURE
	bsf	INDF0, EPSTALL, ACCESS
	goto	sendAnswerOk

getDescriptorRequest
	movlw	GET_DESCRIPTOR
	movwf	USB_dev_req, BANKED	; processing a GET_DESCRIPTOR request
	movf	USB_buffer_data+(wValue+1), W, BANKED
	dispatchRequest	DEVICE, getDeviceDescriptorRequest
	dispatchRequest	CONFIGURATION, getConfigurationDescriptorRequest
	dispatchRequest	STRING, getStringDescriptorRequest
	dispatchRequest	HID, getHidDescriptorRequest
	dispatchRequest	REPORT, getReportDescriptorRequest
	goto		standardRequestsError

getDeviceDescriptorRequest
	movlw	low (Device-Descriptor_begin)
	movwf	USB_desc_ptr, BANKED
	call	Descriptor		; get descriptor length
	movwf	USB_bytes_left, BANKED
	goto	sendDescriptorRequestAnswer

getConfigurationDescriptorRequest
	bcf	USB_error_flags, 0, BANKED
	movf	USB_buffer_data+wValue, W, BANKED
	btfsc	STATUS, Z, ACCESS	; skip if not zero
	goto	getConfigurationDescriptor0
	bsf	USB_error_flags, 0, BANKED
	goto	standardRequestsError
getConfigurationDescriptor0
	movlw	low (Configuration1-Descriptor_begin)
	addlw	0x02			; add offset for wTotalLength
	movwf	USB_desc_ptr, BANKED
	call	Descriptor		; get total descriptor length
	movwf	USB_bytes_left, BANKED
	movlw	0x02
	subwf	USB_desc_ptr, F, BANKED	; subtract offset for wTotalLength
	goto 	sendDescriptorRequestAnswer

getStringDescriptorRequest
	bcf	USB_error_flags, 0, BANKED
	movf	USB_buffer_data+wValue, W, BANKED	; string no
	sublw	2
	btfsc	STATUS,C
	goto	getValidStringDescriptorRequest
	bsf	USB_error_flags, 0, BANKED
	goto	standardRequestsError
getValidStringDescriptorRequest		; allright string index <= 2
	movf	USB_buffer_data+wValue, W, BANKED	; string no
	addlw	low (StringOffsetsTable - Descriptor_begin)
	movwf	USB_desc_ptr, BANKED
	call	Descriptor		; retrieve offset of requested string no
	movwf	USB_desc_ptr, BANKED	; now retrieve the string descriptor itself
	call	Descriptor		; get string descriptor length
	movwf	USB_bytes_left, BANKED
	goto	sendDescriptorRequestAnswer

getHidDescriptorRequest
	bcf	USB_error_flags, 0, BANKED
	movf	USB_buffer_data+wValue, W, BANKED
	btfsc	STATUS, Z, ACCESS	; skip if not zero
	goto	getHidDescriptor0
	bsf	USB_error_flags, 0, BANKED
	goto	standardRequestsError
getHidDescriptor0
	movlw	low (HID1-Descriptor_begin)
	movwf	USB_desc_ptr, BANKED
	call	Descriptor		; get descriptor length
	movwf	USB_bytes_left, BANKED
	goto	sendDescriptorRequestAnswer

getReportDescriptorRequest
	bcf	USB_error_flags, 0, BANKED
	movf	USB_buffer_data+wValue, W, BANKED
	btfsc	STATUS, Z, ACCESS	; skip if not zero
	goto	getReportDescriptor0
	bsf	USB_error_flags, 0, BANKED
	goto	standardRequestsError
getReportDescriptor0
	movlw	REPORT_DESCRIPTOR_LENGTH
	movwf	USB_bytes_left, BANKED	; set descriptor length
	movlw	low (Report1-Descriptor_begin)
	movwf	USB_desc_ptr, BANKED
	goto	sendDescriptorRequestAnswer

classRequests
	movf	USB_buffer_data+bRequest, W, BANKED
	dispatchRequest	GET_REPORT, classGetReport
	dispatchRequest	SET_REPORT, classSetReport
	dispatchRequest	GET_PROTOCOL, classGetProtocol
	dispatchRequest	SET_PROTOCOL, classSetProtocol
	dispatchRequest	GET_IDLE, classGetIdle
	dispatchRequest	SET_IDLE, classSetIdle
	goto	standardRequestsError

classGetReport				; report current LED_state
	banksel	BDIAH
	movf	BDIAH, W, BANKED	; put EP0 IN buffer pointer...
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED
	movwf	FSR0L, ACCESS		; ...into FSR0
	banksel LED_states
	movf	LED_states, W, BANKED	; red led
	movwf	POSTINC0
	movf	LED_states+1, W, BANKED	; yellow led
	movwf	POSTINC0
	movf	LED_states+2, W, BANKED	; green led
	movwf	POSTINC0
	movf	LED_states+3, W, BANKED	; blue led
	movwf	POSTINC0
	movf	LED_states+4, W, BANKED	; white led
	movwf	INDF0			; ...to EP0 IN buffer
	banksel	BDIBC
	movlw	0x05
	movwf	BDIBC, BANKED		; set EP0 IN buffer byte count
	goto	sendAnswer

classSetReport
	movlw	SET_REPORT
	movwf	USB_dev_req, BANKED	; processing a SET_REPORT request
	return

classGetProtocol
	banksel	BDIAH
	movf	BDIAH, W, BANKED	; put EP0 IN buffer pointer...
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED
	movwf	FSR0L, ACCESS		; ...into FSR0
	banksel	USB_protocol
	movf	USB_protocol, W, BANKED
	movwf	INDF0
	banksel	BDIBC
	movlw	0x01
	movwf	BDIBC, BANKED		; set byte count to 1
	goto	sendAnswer

classSetProtocol
	movf	USB_buffer_data+wValue, W, BANKED
	movwf	USB_protocol, BANKED	; update the new protocol value
	goto	sendAnswerOk

classGetIdle
	banksel	BDIAH
	movf	BDIAH, W, BANKED	; put EP0 IN buffer pointer...
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED
	movwf	FSR0L, ACCESS		; ...into FSR0
	banksel	USB_idle_rate
	movf	USB_idle_rate, W, BANKED
	movwf	INDF0
	banksel	BDIBC
	movlw	0x01
	movwf	BDIBC, BANKED		; set byte count to 1
	goto	sendAnswer

classSetIdle
	movf	USB_buffer_data+wValue, W, BANKED
	movwf	USB_idle_rate, BANKED	; update the new idle rate
	goto	sendAnswerOk

processInToken
	banksel	USB_USTAT
	movf	USB_USTAT, W, BANKED
	andlw	0x18			; extract the EP bits
	sublw	EP0
	btfss	STATUS, Z, ACCESS	; skip if it is EP0
	return
	movf	USB_dev_req, W, BANKED
	sublw	GET_DESCRIPTOR
	btfsc	STATUS, Z, ACCESS	; skip if not GET_DESCRIPTOR
	goto	SendDescriptorPacket
	movf	USB_dev_req, W, BANKED
	sublw	SET_ADDRESS
	btfss	STATUS, Z, ACCESS	; skip if it is SET_ADDRESS
	return				; not SET_ADDRESS: just return
	movf	USB_address_pending, W, BANKED
	movwf	UADDR, ACCESS
	movlw	ADDRESS_STATE
	btfsc	STATUS, Z, ACCESS	; skip if USB_address_pending was not zero
	movlw	DEFAULT_STATE		; zero value corresponds to default state
	movwf	USB_USWSTAT, BANKED
	return

processOutToken
	banksel	USB_USTAT
	movf	USB_USTAT, W, BANKED
	andlw	0x18			; extract the EP bits
	sublw	EP0
	btfss	STATUS, Z, ACCESS	; skip if it is EP0
	return
	movf	USB_dev_req, W, BANKED
	sublw	SET_REPORT		; is the request SET_REPORT?
	btfsc	STATUS,Z,ACCESS		; skip if not
	call	setReport
	banksel	BDOBC
	movlw	0x08
	movwf	BDOBC, BANKED
	movlw	0x88
	movwf	BDOST, BANKED
	goto	sendAnswerOk

setReport
	movlw	NO_REQUEST
	movwf	USB_dev_req, BANKED	; clear device request
	banksel	BDOAH
	movf	BDOAH, W, BANKED	; put EP0 OUT buffer pointer...
	movwf	FSR0H, ACCESS
	movf	BDOAL, W, BANKED
	movwf	FSR0L, ACCESS		; ...into FSR0
	; get five bytes in the buffer and copy to LED_states
	banksel	LED_states
	movf	POSTINC0, W	
	movwf	LED_states, BANKED
	movf	POSTINC0, W	
	movwf	LED_states+1, BANKED
	movf	POSTINC0, W	
	movwf	LED_states+2, BANKED
	movf	POSTINC0, W	
	movwf	LED_states+3, BANKED
	movf	INDF0, W	
	movwf	LED_states+4, BANKED
	bsf	USB_received,0,BANKED
	return

sendDescriptorRequestAnswer
	movf	USB_buffer_data+(wLength+1),W,BANKED
	btfss	STATUS,Z,ACCESS		; skip if zero
	goto	SendDescriptorPacket
	movf	USB_bytes_left,W,BANKED
	subwf	USB_buffer_data+wLength,W,BANKED
	btfsc	STATUS,C,ACCESS	
	goto	SendDescriptorPacket	; USB_buffer_data+wLength >= USB_bytes_left
	movf	USB_buffer_data+wLength, W, BANKED
	movwf	USB_bytes_left, BANKED

SendDescriptorPacket
	banksel	USB_bytes_left
	
	movlw	0x08
	subwf	USB_bytes_left,W,BANKED
	btfsc	STATUS,C,ACCESS
	goto	longDescriptor		; bytes_left > 8

	movlw	NO_REQUEST
	movwf	USB_dev_req, BANKED	; sending a short packet, so clear device request
	movf	USB_bytes_left, W, BANKED
	goto	shortDescriptor

longDescriptor
	movlw	0x08

shortDescriptor
	; bytes to send now in W
	subwf	USB_bytes_left, F, BANKED
	movwf	USB_packet_length, BANKED
	banksel	BDIBC
	movwf	BDIBC, BANKED			; set EP0 IN byte count with packet size
	movf	BDIAH, W, BANKED		; put EP0 IN buffer pointer...
	movwf	FSR0H, ACCESS
	movf	BDIAL, W, BANKED
	movwf	FSR0L, ACCESS			; ...into FSR0
	banksel	USB_loop_index

	movlw	1
	movwf	USB_loop_index,BANKED

sendNextDescriptorByte
	movf	USB_loop_index,W,BANKED
	subwf	USB_packet_length,W,BANKED
	btfss	STATUS,C,ACCESS
	goto	descriptorSent

	call	Descriptor		; get next byte of descriptor being sent
	movwf	POSTINC0		; copy to EP0 IN buffer, and increment FSR0
	incf	USB_desc_ptr, F, BANKED	; increment the descriptor pointer
	incf	USB_loop_index,F,BANKED
	goto	sendNextDescriptorByte

descriptorSent
	banksel	BDIST
	movlw	0x40
	xorwf	BDIST, W, BANKED	; toggle the DATA01 bit
	andlw	0x40			; clear the PIDs bits
	iorlw	0x88			; set UOWN and DTS bits
	movwf	BDIST, BANKED
	return

WaitConfiguredUSB
	call	ServiceUSB		; service USB requests...
	banksel	USB_USWSTAT
	movf	USB_USWSTAT,W,BANKED
	sublw	CONFIG_STATE
	btfss	STATUS,Z,ACCESS
	goto	WaitConfiguredUSB	; ...until the host configures the peripheral

	banksel	LED_states
	clrf	LED_states, BANKED
	clrf	LED_states+1, BANKED
	clrf	LED_states+2, BANKED
	clrf	LED_states+3, BANKED
	clrf	LED_states+4, BANKED
	return

			END
