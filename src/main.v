module main

import picoev

const port = 8080

fn main() {
	mut app := App{
		db: DB.connect()
	}
	mut server := picoev.new(
		port: port
		cb: app.callback
	) or { panic(err) }

	println('Server started on port ' + port.str())
	server.serve()
}
