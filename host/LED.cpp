#include "LED.hpp"

LED::LED() : red(false), yellow(false), green(false),blue(false),white(false) {
}

LED::LED(bool r, bool y, bool g, bool b, bool w) : red(r), yellow(y), green(g),
	blue(b), white(w) {
}
