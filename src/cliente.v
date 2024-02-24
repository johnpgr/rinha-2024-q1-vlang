module main

import time
import db.sqlite

@[table: 'cliente']
pub struct Cliente {
pub mut:
	id     int    @[primary; sql: serial]
	nome   string
	limite int
	saldo  int
}

@[inline]
pub fn (mut c Cliente) efetuar_transacao(t &Transacao) ! {
	match t.tipo {
		'd' {
			has_limit := (c.saldo - t.valor) >= (c.limite * -1)

			if !has_limit {
				return error('ERROR: Transação inválida, saldo insuficiente')
			}

			c.saldo -= t.valor
		}
		'c' {
			c.saldo += t.valor
		}
		else {
			panic('WTF?')
		}
	}
}

@[direct_array_access; inline]
pub fn Cliente.find(db sqlite.DB, id int) ?&Cliente {
	found := sql db {
		select from Cliente where id == id
	} or { return none }

	if found.len == 0 {
		return none
	}

	mut cliente := found[0]

	return &cliente
}

pub fn (mut c Cliente) save(db sqlite.DB) ! {
	sql db {
		update Cliente set saldo = c.saldo where id == c.id
	}!
}

pub struct Extrato {
pub mut:
	saldo struct {
		total        int       @[required]
		data_extrato time.Time @[required]
		limite       int       @[required]
	} @[required]

	ultimas_transacoes []TransacaoResponse @[required]
}
