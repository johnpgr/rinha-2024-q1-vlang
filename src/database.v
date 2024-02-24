module main

import db.sqlite

fn sqlite_connect() sqlite.DB {
	return sqlite.connect('./data/database.sqlite3') or { panic(err) }
}

fn init_db(db sqlite.DB) ! {
	db.exec('PRAGMA journal_mode = WAL')!
	db.exec('PRAGMA threads = 4')!
	db.exec('PRAGMA busy_timeout = 30000')!
	db.exec('PRAGMA temp_store = MEMORY')!
	db.exec('PRAGMA cache_size = 10000')!
	db.exec('PRAGMA auto_vacuum = FULL')!
	db.exec('PRAGMA automatic_indexing = TRUE')!
	db.exec('PRAGMA count_changes = FALSE')!
	db.exec('PRAGMA encoding = "UTF-8"')!
	db.exec('PRAGMA ignore_check_constraints = TRUE')!
	db.exec('PRAGMA incremental_vacuum = 0')!
	db.exec('PRAGMA legacy_file_format = FALSE')!
	db.exec('PRAGMA optimize = On')!
	db.exec('PRAGMA synchronous = NORMAL')!

	sql db {
		drop table Cliente
	} or {}

	sql db {
		drop table Transacao
	} or {}

	sql db {
		create table Cliente
		create table Transacao
	}!

	clientes := [
		Cliente{
			id: 1
			nome: 'o barato sai caro'
			limite: 1000 * 100
		},
		Cliente{
			id: 2
			nome: 'zan corp ltda'
			limite: 800 * 100
		},
		Cliente{
			id: 3
			nome: 'les cruders'
			limite: 10000 * 100
		},
		Cliente{
			id: 4
			nome: 'padaria joia de cocaia'
			limite: 100000 * 100
		},
		Cliente{
			id: 5
			nome: 'kid mais'
			limite: 5000 * 100
		},
	]

	for cliente in clientes {
		sql db {
			insert cliente into Cliente
		}!
	}
}
