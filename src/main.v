module main

import vweb
import os

const port = os.getenv_opt('PORT') or { '9999' }.int()

fn main() {
	app := &App{
		db_handle: vweb.database_pool(handler: pg_connect, nr_workers: 4)
	}

	vweb.run_at(app, vweb.RunParams{
		host: '0.0.0.0'
		port: port
		nr_workers: 4
		family: .ip
	}) or { panic(err) }
}
