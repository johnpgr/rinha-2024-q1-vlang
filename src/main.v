module main

import vweb

const port = 8080

fn main() {
	app := &App{
		db_handle: vweb.database_pool(handler: DB.connect)
	}

	vweb.run_at(app, vweb.RunParams{
		host: '0.0.0.0'
		port: port
		family: .ip
	}) or { panic(err) }
}
