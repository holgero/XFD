#ifndef LED_H
#define	LED_H

struct LED {
	bool red, yellow, green;
	LED();
	LED(bool r, bool y, bool g);
};
#endif	/*LED_H */
