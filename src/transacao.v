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
	valor        int       @[required; json: '-']
	tipo         string    @[required]
	descricao    string    @[required]
	realizada_em time.Time = time.now()
}

pub fn (t &Transacao) validate() ! {
	if t.descricao.len > 10 {
		return error('Descrição muito longa')
	}
	if t.valor <= 0 {
		return error('Valor inválido')
	}
}

pub fn Transacao.from_json(json_str string, cliente_id int) !&Transacao {
	mut t := json.decode(Transacao, json_str) or {
		return error('Erro ao decodificar JSON (${err.msg()})')
	}

	t.cliente_id = cliente_id
	t.validate()!

	return &t
}

pub fn Transacao.last_ten(conn pg.DB, cliente_id int) ![]Transacao {
	return sql conn {
		select from Transacao where cliente_id == cliente_id order by realizada_em desc limit 10
	}!
}

pub fn (t &Transacao) save(conn pg.DB) ! {
	sql conn {
		insert t into Transacao
	}!
}
