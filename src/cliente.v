module main

import orm

@[table: 'cliente']
struct Cliente {
pub mut:
	id         int         @[primary; sql: serial]
	limite     i64
	saldo      i64
	transacoes []Transacao @[fkey: 'cliente_id']
}

fn Cliente.new(limite i64, saldo i64) &Cliente {
	c := Cliente{
		limite: limite
		saldo: saldo
	}

	return &c
}

fn (mut c Cliente) efetuar_transacao(t &Transacao) ! {
	if t.tipo == TipoTransacao.debito {
		if c.saldo - t.valor < -(c.limite) {
			return error('ERROR: Transacao invalida, saldo insuficiente')
		}

		c.saldo -= t.valor
		c.transacoes << t
		return
	}

	if c.limite - t.valor < 0 {
		return error('ERROR: Transacao invalida, limite insuficiente')
	}

	c.limite -= t.valor
	c.transacoes << t
}

fn (c &Cliente) save(conn orm.Connection) ! {
	sql conn {
		insert c into Cliente
	}!
}

