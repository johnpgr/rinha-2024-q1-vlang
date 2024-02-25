module main

import vweb

const port = 8080

fn main() {
	db := pg_connect()
	clientes := Cliente.find_all(db)
	db.close()
	mut cliente_map := map[int]Cliente{}

	for cliente in clientes {
		cliente_map[cliente.id] = cliente
	}

	app := &App{
		db_handle: vweb.database_pool(handler: pg_connect)
		clientes: cliente_map
	}

	vweb.run_at(app, vweb.RunParams{
		host: '0.0.0.0'
		port: port
		family: .ip
	}) or { panic(err) }
}
