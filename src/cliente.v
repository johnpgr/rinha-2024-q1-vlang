module main

import time
import db.pg

@[table: 'cliente']
pub struct Cliente {
pub mut:
	id     int    @[primary; sql: serial]
	limite int
	saldo  &Saldo @[required; skip]
}

@[inline]
pub fn (mut c Cliente) efetuar_transacao(t &Transacao) ! {
	tipo_transacao := TipoTransacao.from_str(t.tipo)!

	match tipo_transacao {
		.debito {
			has_limit := (c.saldo.valor - t.valor) >= (c.limite * -1)

			if !has_limit {
				return error('ERROR: Transação inválida, saldo insuficiente')
			}

			c.saldo.valor -= t.valor
		}
		.credito {
			c.saldo.valor += t.valor
		}
	}
}

@[direct_array_access; inline]
pub fn Cliente.find(conn pg.DB, id int) ?&Cliente {
	found := sql conn {
		select from Cliente where id == id
	} or { return none }

	if found.len == 0 {
		return none
	}

	mut cliente := found[0]

	cliente.saldo = Saldo.find(conn, found[0].id)

	return &cliente
}

@[table: 'saldo']
pub struct Saldo {
	id         int @[primary; sql: serial]
	cliente_id int
pub mut:
	valor int
}

@[direct_array_access; inline]
pub fn Saldo.find(conn pg.DB, cliente_id int) &Saldo {
	saldo := sql conn {
		select from Saldo where cliente_id == cliente_id
	} or { panic(err) }

	return &saldo[0]
}

@[inline]
pub fn (mut s Saldo) save(conn pg.DB) ! {
	result := conn.exec_param_many(r'
		UPDATE "saldo" SET "valor" = $1 WHERE "cliente_id" = $2
		RETURNING "valor" as "saldo"
	',
		[s.valor.str(), s.cliente_id.str()]) or { return error('ERROR: Falha ao atualizar saldo') }

	novo_saldo := result[0].vals[0]

	if novo_saldo == none {
		return error('ERROR: Falha ao atualizar saldo')
	}

	// int() casts i64 to int; parse_int(10,32) parses string to a base 10 int 32 bits
	// this should in theory never panic
	s.valor = int((novo_saldo as string).parse_int(10, 32) or { panic(err) })
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
