module main

import x.json2
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
	extrato := Cliente.get_extrato(app.db, cliente_id) or {
		return app.internal_error()
	}

	return app.json2(extrato)
}

@['/clientes/:id/transacoes'; post]
pub fn (mut app App) handle_transacao(cliente_id int) vweb.Result {
	if cliente_id < 1 || cliente_id > 5 {
		return app.not_found()
	}

	transacao := Transacao.from_req(app.req.data, cliente_id) or {
		debug('[UNPROCESSABLE] ${err.msg()} ${app.req.data}')
		return app.unprocessable()
	}

	valor_transacao := if transacao.tipo == 'd' {
		transacao.valor * -1
	} else {
		transacao.valor
	}

	saldo, limite := Cliente.efetuar_transacao(app.db, cliente_id, valor_transacao) or {
		debug('[UNPROCESSABLE] ${err.msg()} ${app.req.data}')
		return app.unprocessable()
	}

	transacao.save(app.db) or { panic(err) }

	return app.json2({
		'limite': limite
		'saldo':  saldo
	})
}

@['/admin/reset'; post]
fn (mut app App) handle_admin_reset_db() vweb.Result {
	app.db.exec('UPDATE cliente SET saldo = 0') or { panic(err) }
	app.db.exec('DELETE FROM transacao') or { panic(err) }

	return app.text('Ok')
}


fn (mut ctx App) json2[T](data T) vweb.Result {
	mut buffer := []u8{cap: 2048}

	defer {
		unsafe { buffer.free() }
	}

	encoder := json2.Encoder{
		escape_unicode: false
	}

	encoder.encode_value(data, mut buffer) or { panic(err) }

	ctx.set_content_type('application/json')

	return ctx.text(buffer.bytestr())
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
