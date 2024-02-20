module main

@[if debug; inline]
pub fn debug[T](s T) {
	println(s)
}
