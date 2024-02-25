module main

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
