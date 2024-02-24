module main

@[inline]
pub fn (app &App) handle_extrato(cliente_id int) (string, &Response) {
	cliente := Cliente.find(app.db, cliente_id) or { return Response.not_found() }
	ultimas_transacoes := Transacao.last_ten(app.db, cliente_id) or {
		debug('[INTERNAL_SERVER_ERROR] ${err.msg()}')
		return Response.internal_error()
	}

	return Response.json(Extrato{
		saldo: struct {
			total: cliente.saldo.valor
			data_extrato: fast_time_now()
			limite: cliente.limite
		}
		ultimas_transacoes: ultimas_transacoes.to_response()
	})
}

@[inline]
pub fn (app &App) handle_transacao(body string, cliente_id int) (string, &Response) {
	transacao := Transacao.from_json(body, cliente_id) or {
		debug('[BAD_REQUEST] ${err.msg()} ${body}')
		return Response.bad_request()
	}

	mut cliente := Cliente.find(app.db, cliente_id) or {
		debug('[NOT_FOUND] ${err.msg()} ${body}')
		return Response.not_found()
	}

	cliente.efetuar_transacao(transacao) or {
		debug('[UNPROCESSABLE] ${err.msg()} ${body}')
		return Response.unprocessable()
	}

	db := DB(app.db)

	db.begin()
	db.xact_lock(cliente_id.str())
	transacao.save(db) or {
		debug('[INTERNAL_SERVER_ERROR]${err.msg()} ${body}')
		db.rollback()
		return Response.internal_error()
	}
	cliente.saldo.save(db) or {
		debug('[INTERNAL_SERVER_ERROR] ${err.msg()} ${body}')
		db.rollback()
		return Response.internal_error()
	}
	db.commit()

	return Response.json({
		'limite': cliente.limite
		'saldo':  cliente.saldo.valor
	})
}

@[inline]
fn (app &App) handle_admin_reset() (string, &Response) {
	db := DB(app.db)
	db.begin()
	db.exec('UPDATE "saldo" SET "valor" = 0') or { panic(err) }
	db.exec('DELETE FROM "transacao"') or { panic(err) }
	db.commit()

	return Response.ok()
}
