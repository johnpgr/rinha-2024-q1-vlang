module main

import vweb

@['/clientes/:id/extrato']
pub fn (mut app App) handle_extrato(cliente_id int) vweb.Result {
	if cliente_id > 5 || cliente_id < 1 {
		return app.not_found()
	}
	cliente := app.clientes[cliente_id]

	ultimas_transacoes := Transacao.last_ten(app.db, cliente.id) or {
		debug('[INTERNAL_SERVER_ERROR]: ${err.msg()} cliente: ${cliente}')
		return app.internal_error()
	}

	return app.json2(Extrato{
		saldo: struct {
			total: cliente.saldo
			data_extrato: fast_time_now()
			limite: cliente.limite
		}
		ultimas_transacoes: ultimas_transacoes.to_response()
	})
}

@['/clientes/:id/transacoes'; post]
pub fn (mut app App) handle_transacao(cliente_id int) vweb.Result {
	if cliente_id > 5 || cliente_id < 1 {
		return app.not_found()
	}
	mut cliente := app.clientes[cliente_id]

	transacao := Transacao.from_json(app.req.data, cliente.id) or {
		debug('[BAD_REQUEST] ${err.msg()} ${app.req.data}')
		return app.unprocessable()
	}

	cliente.efetuar_transacao(transacao) or {
		debug('[UNPROCESSABLE]: ${err.msg()} cliente: ${cliente} body: ${app.req.data}')
		return app.unprocessable()
	}

	begin(app.db)
	xact_lock(app.db, cliente_id)
	transacao.save(app.db) or {
		debug('[INTERNAL_SERVER_ERROR]: ${err.msg()} cliente: ${cliente} body: ${app.req.data}')
		return app.internal_error()
	}
	cliente.save(app.db) or {
		debug('[INTERNAL_SERVER_ERROR]: ${err.msg()} cliente: ${cliente} body: ${app.req.data}')
		return app.internal_error()
	}
	commit(app.db)

	return app.json2({
		'limite': cliente.limite
		'saldo':  cliente.saldo
	})
}

@['/admin/reset'; post]
fn (mut app App) handle_admin_reset_db() vweb.Result {
	begin(app.db)
	app.db.exec('UPDATE cliente SET saldo = 0') or { panic(err) }
	app.db.exec('DELETE FROM transacao') or { panic(err) }
	commit(app.db)

	return app.text('Ok')
}
