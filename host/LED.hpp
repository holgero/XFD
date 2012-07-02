#ifndef LED_H
#define	LED_H

struct LED {
	bool red, yellow, green, blue, white;
	LED();
	LED(bool r, bool y, bool g, bool b, bool w);
};
#endif	/*LED_H */
