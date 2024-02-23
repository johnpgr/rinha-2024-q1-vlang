module main

import vweb
import time

@['/clientes/:id/extrato'; get]
pub fn (mut ctx App) handle_extrato(cliente_id int) vweb.Result {
	cliente := Cliente.find(ctx.db, cliente_id) or { return ctx.not_found() }
	ultimas_transacoes := Transacao.last_ten(ctx.db, cliente_id) or {
		debug('[INTERNAL_SERVER_ERROR] ${err.msg()}')
		return ctx.internal_error()
	}

	return ctx.json2(Extrato{
		saldo: struct {
			total: cliente.saldo.valor
			data_extrato: time.now()
			limite: cliente.limite
		}
		ultimas_transacoes: ultimas_transacoes
	})
}

@['/clientes/:id/transacoes'; post]
pub fn (mut ctx App) handle_transacao(cliente_id int) vweb.Result {
	transacao := Transacao.from_json(ctx.req.data, cliente_id) or {
		debug('[BAD_REQUEST] ${err.msg()} ${ctx.req.data}')
		return ctx.bad_request()
	}

	mut cliente := Cliente.find(ctx.db, cliente_id) or {
		debug('[NOT_FOUND] ${err.msg()} ${ctx.req.data}')
		return ctx.not_found()
	}

	cliente.efetuar_transacao(transacao) or {
		debug('[UNPROCESSABLE] ${err.msg()} ${ctx.req.data}')
		return ctx.unprocessable()
	}

	db := DB(ctx.db)

	db.begin() or { panic(err) }

	db.xact_lock(cliente_id) or { panic(err) }

	transacao.save(db) or {
		debug('[INTERNAL_SERVER_ERROR]${err.msg()} ${ctx.req.data}')
		return ctx.internal_error()
	}

	cliente.saldo.save(db) or {
		debug('[INTERNAL_SERVER_ERROR] ${err.msg()} ${ctx.req.data}')
		return ctx.internal_error()
	}

	db.commit() or { panic(err) }

	return ctx.json2({
		'limite': cliente.limite
		'saldo':  cliente.saldo.valor
	})
}

@['/admin/reset'; post]
fn (mut ctx App) handle_admin_reset_db() vweb.Result {
	db := DB(ctx.db)
	db.begin() or { panic(err) }
	db.exec('UPDATE "saldo" SET "valor" = 0') or { panic(err) }
	db.exec('DELETE FROM "transacao"') or { panic(err) }
	db.commit() or { panic(err) }

	return ctx.text('Ok')
}
