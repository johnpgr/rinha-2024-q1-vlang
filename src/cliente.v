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

@[inline]
pub fn Cliente.new(limite int, saldo int) &Cliente {
	c := Cliente{
		limite: limite
		saldo: saldo
	}

	return &c
}

@[inline]
pub fn (mut c Cliente) efetuar_transacao(t &Transacao) ! {
	match t.tipo {
		.debito {
			if Int(c.saldo - t.valor).abs() < c.limite {
				return error('ERROR: Transação inválida, saldo insuficiente')
			}

			c.saldo -= t.valor
			return
		}
		.credito {
			c.saldo += t.valor
		}
	}
}

@[inline]
pub fn (c &Cliente) save(conn orm.Connection) ! {
	sql conn {
		update Cliente set limite = c.limite, saldo = c.saldo where id == c.id
	}!
}

@[direct_array_access; inline]
pub fn Cliente.find(conn orm.Connection, id int) ?&Cliente {
	found := sql conn {
		select from Cliente where id == id
	} or { return none }

	if found.len == 0 {
		return none
	}

	return &found[0]
}

pub struct Extrato {
pub mut:
	saldo struct {
		total        int       @[required]
		data_extrato time.Time @[required]
		limite       int       @[required]
	} @[required]

	ultimas_transacoes []Transacao @[required]
}

@[inline]
pub fn (app &App) handle_extrato(cliente_id int) &Response {
	cliente := Cliente.find(app.db, cliente_id) or { return Response.not_found() }
	ultimas_transacoes := Transacao.last_ten(app.db, cliente_id) or {
		return Response.internal_error()
	}

	return Response.json(Extrato{
		saldo: struct {
			total: cliente.saldo
			data_extrato: time.now()
			limite: cliente.limite
		}
		ultimas_transacoes: ultimas_transacoes
	})
}
