module main

import db.pg
import vweb

struct App {
	vweb.Context
pub mut:
	db        pg.DB
	db_handle vweb.DatabasePool[pg.DB] @[required]
}

@['/clientes/:id/extrato']
pub fn (mut app App) handle_extrato(cliente_id int) vweb.Result {
	if cliente_id < 1 || cliente_id > 5 {
		return app.not_found()
	}

	cliente := Cliente.find(app.db, cliente_id) or { return app.internal_error() }
	extrato := Extrato{
		saldo: struct {
			total: cliente.saldo
			data_extrato: fast_time_now()
			limite: cliente.limite
		},
		ultimas_transacoes: cliente.ultimas_transacoes
	}

	return app.json2(extrato)
}

@['/clientes/:id/transacoes'; post]
pub fn (mut app App) handle_transacao(cliente_id int) vweb.Result {
	if cliente_id < 1 || cliente_id > 5 {
		return app.not_found()
	}

	transacao := Transacao.from_json(app.req.data) or {
		debug('[UNPROCESSABLE] ${err.msg()} ${app.req.data}')
		return app.unprocessable()
	}

	t_res := Cliente.efetuar_transacao(app.db, cliente_id, transacao) or {
		debug('[UNPROCESSABLE] ${err.msg()} ${app.req.data}')
		return app.unprocessable()
	}

	return app.json2(t_res)
}

fn (mut ctx App) json2[T](data T) vweb.Result {
	json_to_send := fast_json_encode(data) or { return ctx.internal_error() }

	ctx.set_content_type('application/json')

	return ctx.text(json_to_send)
}

fn (mut ctx App) unprocessable() vweb.Result {
	ctx.set_status(422, '')
	return ctx.text('')
}

fn (mut ctx App) internal_error() vweb.Result {
	ctx.set_status(500, '')
	return ctx.text('')
}

fn (mut ctx App) bad_request() vweb.Result {
	ctx.set_status(400, '')
	return ctx.text('')
}
