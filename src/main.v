module main

import picoev
import os

const port = if os.getenv('PORT').int() == 0 {
	9999
} else {
	os.getenv('PORT').int()
}

fn main() {
	mut app := App{
		db: create_connection()
	}
	mut server := picoev.new(
		port: port
		cb: app.callback
	) or { panic(err) }

	println('Server started on port ' + port.str())
	server.serve()
}
