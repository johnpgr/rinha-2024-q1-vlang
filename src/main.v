module main

import picoev

const port = 8080

fn main() {
	db := sqlite_connect()

	init_db(db) or { eprintln('Falha ao iniciar banco de dados: ${err.msg()}') }

	mut app := App{
		db: db
	}

	mut server := picoev.new(
		port: port
		cb: app.callback
	) or { panic(err) }

	println('Server started on port ' + port.str())
	server.serve()
}
