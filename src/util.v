module main

@[if debug; inline]
pub fn debug[T](s T) {
	println(s)
}

type Int = int

// abs returns the absolute value of i.
fn (i Int) abs() Int {
	if i < 0 {
		return -i
	}
	return i
}
