module main

import time
import db.pg

@[table: 'cliente']
pub struct Cliente {
pub mut:
	id     int    @[primary; sql: serial]
	nome   string
	limite int
	saldo  int
}

pub fn (c &Cliente) save(db pg.DB) ! {
	sql db {
		update Cliente set saldo = c.saldo where id == c.id
	}!
}

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

pub fn Cliente.find_all(db pg.DB) []Cliente {
	return sql db {
		select from Cliente
	} or { [] }
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
