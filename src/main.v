module main

import picoev

const port = 8080

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
