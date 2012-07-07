#define	NUM_CONFIGURATIONS	1
#define	NUM_INTERFACES		1

; Define the states that the USB interface can be in
#define	POWERED_STATE	0x00
#define	DEFAULT_STATE	0x01
#define	ADDRESS_STATE	0x02
#define	CONFIG_STATE	0x03

#define ENDPT_IN_ONLY	0x12
#define ENDPT_OUT_ONLY	0x14
#define ENDPT_CONTROL	0x16	; enable for in, out and setup

#define TOKEN_OUT	(0x01<<2)
#define TOKEN_IN	(0x09<<2)
#define TOKEN_SETUP	(0x0D<<2)

; Define buffer descriptor table register mapping for no ping-pong buffers
#define BD0OST	0x0400
#define BD0OBC	0x0401
#define BD0OAL	0x0402
#define BD0OAH	0x0403
#define BD0IST	0x0404
#define BD0IBC	0x0405
#define BD0IAL	0x0406
#define BD0IAH	0x0407
#define BD1OST	0x0408
#define BD1OBC	0x0409
#define BD1OAL	0x040A
#define BD1OAH	0x040B
#define BD1IST	0x040C
#define BD1IBC	0x040D
#define BD1IAL	0x040E
#define BD1IAH	0x040F

#define USB_Buffer	0x0480	; Register location after last buffer descriptor register

; offsets from the beginning of the Buffer Descriptor
#define	ADDRESSL	0x02
#define ADDRESSH	0x03

; standard descriptor types
#define	DEVICE		1
#define	CONFIGURATION	2
#define	STRING		3
#define	INTERFACE	4
#define	ENDPOINT	5

; HID class descriptor types
#define HID		0x21
#define REPORT		0x22
#define PHYSICAL	0x23

; offsets from the beginning of the setup data record
#define	bmRequestType	0x00
#define	bRequest	0x01
#define	wValue		0x02
#define	wIndex		0x04
#define	wLength		0x06

; Standard USB requests
#define NO_REQUEST		0xFF
#define	GET_STATUS		0x00
#define	CLEAR_FEATURE		0x01
#define	SET_FEATURE		0x03
#define	SET_ADDRESS		0x05
#define	GET_DESCRIPTOR		0x06
#define SET_DESCRIPTOR		0x07
#define	GET_CONFIGURATION	0x08
#define	SET_CONFIGURATION	0x09
#define	GET_INTERFACE		0x0A
#define	SET_INTERFACE		0x0B

; HID Class requests
#define GET_REPORT	0x01
#define GET_IDLE	0x02
#define GET_PROTOCOL	0x03
#define SET_REPORT	0x09
#define SET_IDLE	0x0A
#define SET_PROTOCOL	0x0B

#define	HID_SET_REPORT	0x21

#define EP0		0x00 << 3
#define EP1		0x01 << 3
#define EP2		0x02 << 3

#define STANDARD	0x00 << 5
#define CLASS		0x01 << 5
#define VENDOR		0x02 << 5

#define RECIPIENT_DEVICE	0x00
#define RECIPIENT_INTERFACE	0x01
#define RECIPIENT_ENDPOINT	0x02

#define DEVICE_REMOTE_WAKEUP	0x01
