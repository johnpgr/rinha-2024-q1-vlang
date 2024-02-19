module main

import time
import orm

@[table: 'cliente']
pub struct Cliente {
pub mut:
	id     int @[primary; sql: serial]
	limite int
	saldo  int
}

pub fn Cliente.new(limite int, saldo int) &Cliente {
	c := Cliente{
		limite: limite
		saldo: saldo
	}

	return &c
}

pub fn (mut c Cliente) efetuar_transacao(t &Transacao) ! {
	if t.tipo == TipoTransacao.debito {
		if c.saldo - t.valor < -(c.limite) {
			return error('ERROR: Transação inválida, saldo insuficiente')
		}

		c.saldo -= t.valor
		return
	}

	if c.limite - t.valor < 0 {
		return error('ERROR: Transação inválida, limite insuficiente')
	}

	c.limite -= t.valor
}

pub fn (c &Cliente) save(conn orm.Connection) ! {
	count := sql conn {
		select count from Cliente where id == c.id
	}!

	if count != 0 {
		sql conn {
			update Cliente set limite = c.limite, saldo = c.saldo where id == c.id
		}!
		return
	}

	sql conn {
		insert c into Cliente
	}!
}

pub fn Cliente.find(conn orm.Connection, id int) ?&Cliente {
	found := sql conn {
		select from Cliente where id == id
	} or { return none }

	if found.len == 0 {
		return none
	}

	return &found[0]
}

pub struct ExtratoSaldo {
pub mut:
	valor        int       @[required]
	data_extrato time.Time @[required]
	limite       int       @[required]
}

pub struct ExtratoResponse {
pub mut:
	saldo              ExtratoSaldo @[required]
	ultimas_transacoes []Transacao  @[required]
}

@[inline]
pub fn (app &App) handle_extrato(cliente_id int) &Response {
	cliente := Cliente.find(app.db, cliente_id) or { return Response.not_found() }
	ultimas_transacoes := Transacao.find_many(app.db, cliente_id, 10) or {
		return Response.internal_error()
	}

	return Response.json(ExtratoResponse{
		saldo: ExtratoSaldo{
			valor: cliente.saldo
			data_extrato: time.now()
			limite: cliente.limite
		}
		ultimas_transacoes: ultimas_transacoes
	})
}
