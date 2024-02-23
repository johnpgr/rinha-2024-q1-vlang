module main

import time
import json
import db.pg

pub enum TipoTransacao {
	debito
	credito
}

fn TipoTransacao.from_str(s string) !TipoTransacao {
	match s {
		'd' {
			return TipoTransacao.debito
		}
		'c' {
			return TipoTransacao.credito
		}
		else {
			return error('ERRO: Tipo de transação inválido')
		}
	}
}

fn (t TipoTransacao) str() string {
	match t {
		.debito {
			return 'd'
		}
		.credito {
			return 'c'
		}
	}
}

@[table: 'transacao']
pub struct Transacao {
pub mut:
	cliente_id   int       @[json: '-']
	valor        int
	tipo         string    @[sql_type: 'CHAR(1)']
	descricao    string
	realizada_em time.Time
}

@[inline]
pub fn Transacao.from_json(json_str string, cliente_id int) !&Transacao {
	mut t := json.decode(Transacao, json_str)!

	if t.descricao.len > 10 {
		return error('ERROR: Descrição longa de mais')
	}

	t.cliente_id = cliente_id
	t.realizada_em = time.now()

	return &t
}

@[inline]
pub fn Transacao.last_ten(conn pg.DB, cliente_id int) ![]Transacao {
	return sql conn {
		select from Transacao where cliente_id == cliente_id order by realizada_em desc limit 10
	}!
}

@[inline]
pub fn (t &Transacao) save(conn pg.DB) ! {
	sql conn {
		insert t into Transacao
	}!
}
