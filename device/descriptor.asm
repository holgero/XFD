; USB Firmware for PICs
; descriptors for USB
; Copyright (C) 2012 Holger Oehm
;
; Licensed under the Apache License, Version 2.0 (the "License");
; you may not use this file except in compliance with the License.
; You may obtain a copy of the License at
;
;     http://www.apache.org/licenses/LICENSE-2.0
;
; Unless required by applicable law or agreed to in writing, software
; distributed under the License is distributed on an "AS IS" BASIS,
; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
; See the License for the specific language governing permissions and
; limitations under the License.

;**************************************************************
; includes
#include <p18f13k50.inc>
#include <descriptor.inc>

;**************************************************************
; exported subroutines
	global	copyNextDescriptorByte
	; copies next byte of descriptor to INDFINC0

	global	getIndexedString
	; prepares copying a string descriptor
	; W in: index of string
	; W out: first byte of string descriptor (== length)

	global	getCompatibleIdFeature
	; prepares copying the CompatibleIdFeature
	; W out: first byte of CompatibleIdFeature (== length)

	global	getDeviceDescriptor
	; prepares copying the Device descriptor
	; W out: first byte of Device descriptor (== length)

	global	getConfigurationDescriptor
	; prepares copying an Configuration descriptor
	; W out: third byte of ConfigurationDescriptor (== totalLength)

;**************************************************************
; local declarations
VID		EQU		0x1d50
PID		EQU		0x6039

;**************************************************************
; local data
descriptor_udata	UDATA
nextDescriptorIdx	RES	1

;**************************************************************
; local temp data
descriptor_udata_ovr	UDATA_OVR
length_tmp		RES	1

;**************************************************************
; code section
descriptor_code		CODE	0x0f00

copyNextDescriptorByte
	call	getDescriptor
	movwf	POSTINC0		; copy to EP0 IN buffer, and increment FSR0
	incf	nextDescriptorIdx, F, BANKED	; increment the descriptor pointer
	return

getDescriptor
	movlw	upper Descriptor_begin
	movwf	TBLPTRU, ACCESS
	movlw	high Descriptor_begin
	movwf	TBLPTRH, ACCESS
	movlw	low Descriptor_begin
	banksel	nextDescriptorIdx
	addwf	nextDescriptorIdx, W, BANKED
	btfss	STATUS, C, ACCESS
	goto	decriptorAddressCalculated
	incfsz	TBLPTRH, F, ACCESS
	goto	decriptorAddressCalculated
	incf	TBLPTRU, F, ACCESS
decriptorAddressCalculated
	movwf	TBLPTRL, ACCESS
	tblrd*
	movf	TABLAT, W, ACCESS
	return

getIndexedString
	; input in W: index of string
	; output in W: first byte of string descriptor == length
	addlw	low (StringOffsetsTable - Descriptor_begin)
	movwf	nextDescriptorIdx, BANKED
	call	getDescriptor		; returns value from the StringOffsetsTable in W
	movwf	nextDescriptorIdx, BANKED	; now retrieve the string descriptor itself
	goto	getDescriptor			; first byte of descriptor == length

getCompatibleIdFeature
	movlw	low (CompatibleIdFeature-Descriptor_begin)
	movwf	nextDescriptorIdx, BANKED
	goto	getDescriptor		; get first byte == length

getDeviceDescriptor
	movlw	low (Device-Descriptor_begin)
	movwf	nextDescriptorIdx, BANKED
	goto	getDescriptor		; get first byte == length

getConfigurationDescriptor
	movlw	low (Configuration1-Descriptor_begin)
	addlw	0x02			; add offset for wTotalLength
	movwf	nextDescriptorIdx, BANKED
	call	getDescriptor		; get total descriptor length
	banksel	length_tmp
	movwf	length_tmp, BANKED
	movlw	0x02
	banksel	nextDescriptorIdx
	subwf	nextDescriptorIdx, F, BANKED	; subtract offset for wTotalLength
	banksel	length_tmp
	movf	length_tmp, W, BANKED
	return


Descriptor_begin
Device
db	0x12, DEVICE			; bLength, bDescriptorType
db	0x00, 0x02			; low(bcdUSB), high(bcdUSB): 2.00
db	0xFF, 0x00			; bDeviceClass, bDeviceSubClass
db	0x00, 0x08			; bDeviceProtocl, bMaxPacketSize
db	low(VID), high(VID)		; low(idVendor), high(idVendor)
db	low(PID), high(PID)		; low(idProduct), high(idProduct)
db	0x01, 0x00			; low(bcdDevice), high(bcdDevice)
db	0x01, 0x02			; iManufacturer, iProduct
db	0x00, NUM_CONFIGURATIONS	; iSerialNumber (none), bNumConfigurations

Configuration1
db	0x09, CONFIGURATION		; bLength, bDescriptorType
db	0x19, 0x00			; low(wTotalLength), high(wTotalLength)
db	NUM_INTERFACES, 0x01		; bNumInterfaces, bConfigurationValue
db	0x00, 0x80			; iConfiguration (none), bmAttributes
db	0x32, 0x09			; bMaxPower (100 mA), interface1: blength
db	INTERFACE, 0x00			; INTERFACE, 0x00
db	0x00, 0x01			; bAlternateSetting, bNumEndpoints (excluding EP0)
db	0xFF, 0x00			; bInterfaceClass (vendor specific), bInterfaceSubClass (no subclass)
db	0x00, 0x00			; bInterfaceProtocol (none), iInterface (none)
db	0x07, ENDPOINT			; EP0: bLength, bDescriptorType
db	0x81, 0x03			; bEndpointAddress (EP1 IN), bmAttributes (Interrupt)
db	0x08, 0x00			; low(wMaxPacketSize), high(wMaxPacketSize)
db	0x0A				; bInterval (10 ms)

CompatibleIdFeature                     ; MS extension
db	0x28, 0x00			; low(descriptorLength), high(descriptorLength)
db	0x00, 0x00			; more lenght bytes, set to 0
db	0x00, 0x01			; bcd version ('1.0')
db	0x04, 0x00			; Compatibility ID Descriptor index (0x0004)
db	0x01, 0x00			; Number of sections (1), reserved
db	0x00, 0x00
db	0x00, 0x00
db	0x00, 0x00			; 6 reserved bytes
db	0x00, 0x01			; Interface Number (Interface #0), Reserved
db	'W', 'I', 'N', 'U', 'S', 'B'	; "WINUSB"
db	0x00, 0x00			; "\0\0"
db	0x00, 0x00, 0x00, 0x00
db	0x00, 0x00, 0x00, 0x00		; Sub-Compatible ID (unused)
db	0x00, 0x00, 0x00, 0x00
db	0x00, 0x00			; Reserved 

String0
db	String1-String0, STRING		; bLength, bDescriptorType
db	0x09, 0x04			; wLANGID[0]=0x0409: English (US)
String1
db	String2-String1, STRING		; bLength, bDescriptorType
db	'H', 0x00			; bString
db	'o', 0x00
db	'l', 0x00
db	'g', 0x00
db	'e', 0x00
db	'r', 0x00
db	' ', 0x00
db	'O', 0x00
db	'e', 0x00
db	'h', 0x00
db	'm', 0x00
String2
db	StringEE-String2, STRING	; bLength, bDescriptorType
db	'X', 0x00			; bString
db	'F', 0x00
db	'D', 0x00
db	'e', 0x00
db	'v', 0x00
db	'i', 0x00
db	'c', 0x00
db	'e', 0x00
StringEE				; special string to enable ms extensions
db	Descriptor_end-StringEE, STRING	; bLength, bDescriptorType=STRING
db	'M', 0x00
db	'S', 0x00
db	'F', 0x00
db	'T', 0x00
db	'1', 0x00
db	'0', 0x00
db	'0', 0x00
db	VENDOR_CODE, 0x00		; Vendor Code, padding
Descriptor_end

StringOffsetsTable
db	String0 - Descriptor_begin, String1 - Descriptor_begin
db	String2 - Descriptor_begin, StringEE - Descriptor_begin

			END
