module main

import os
import db.pg

const db_name = os.getenv_opt('DB_NAME') or { panic('DB_NAME not set') }
const db_user = os.getenv_opt('DB_USER') or { panic('DB_USER not set') }
const db_pass = os.getenv_opt('DB_PASS') or { panic('DB_PASS not set') }
const db_host = os.getenv_opt('DB_HOST') or { panic('DB_HOST not set') }
const db_port = os.getenv_opt('DB_PORT') or { panic('DB_PORT not set') }.int()

fn pg_connect() pg.DB {
	return pg.connect(
		host: db_host
		port: db_port
		user: db_user
		password: db_pass
		dbname: db_name
	) or { panic(err) }
}

fn xact_lock(db pg.DB, cliente_id int) {
	db.exec_param(r'SELECT pg_advisory_xact_lock($1)', cliente_id.str()) or { panic(err) }
}

fn begin(db pg.DB) {
	db.exec('BEGIN') or { panic(err) }
}

fn commit(db pg.DB) {
	db.exec('COMMIT') or { panic(err) }
}
