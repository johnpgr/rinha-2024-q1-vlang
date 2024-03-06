module main

import x.json2
import time

@[inline]
pub fn fast_time_now() time.Time {
	mut ts := C.timespec{}
	C.clock_gettime(C.CLOCK_REALTIME_COARSE, &ts)

	return time.unix_nanosecond(i64(ts.tv_sec), int(ts.tv_nsec))
}

@[if debug; inline]
pub fn debug[T](s T) {
	println(s)
}

@[inline]
pub fn fast_json_encode[T](data T) !string {
	mut buffer := []u8{cap: 2048}

	defer {
		unsafe { buffer.free() }
	}

	encoder := json2.Encoder {
		escape_unicode:
		false
	}
	encoder.encode_value(data, mut buffer)!

	return buffer.bytestr()
}
