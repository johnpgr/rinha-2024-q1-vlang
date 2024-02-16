module main

import db.pg

const db_name = "rinha-2024-q1"
const db_user = "user"
const db_pass = "1234"
const db_host = "0.0.0.0"
const db_port = 5432

fn create_connection() pg.DB {
	return pg.connect(
		host: db_host
		port: db_port
		user: db_user
		password: db_pass
		dbname: db_name
	) or { panic(err) }
}

fn init_tables() {
	conn := create_connection()

	sql conn {
		drop table Cliente
		drop table Transacao
	} or { panic('Failed to drop tables') }

	sql conn {
		create table Cliente
		create table Transacao
	} or { panic('Failed to create tables') }
}

fn insert_test_clientes() {
	limites := [100000, 80000, 1000000, 10000000, 500000]

	mut clientes := []Cliente{}

	for limite in limites {
		cliente := Cliente{
			limite: u64(limite)
			saldo: 0
		}

		clientes << cliente
	}

	conn := create_connection()

	for cliente in clientes {
		sql conn {
			insert cliente into Cliente
		} or { panic(err)}
	}
}
