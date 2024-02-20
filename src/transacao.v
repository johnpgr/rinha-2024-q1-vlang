module main

import time
import x.json2
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
	cliente_id   int
	valor        int
	tipo         string    @[sql_type: 'CHAR(1)']
	descricao    string
	realizada_em time.Time
}

@[inline]
pub fn Transacao.new(cliente_id int, valor int, tipo TipoTransacao, descricao string) !&Transacao {
	if descricao.len > 10 {
		return error('Descrição muito longa')
	}
	if valor <= 0 {
		return error('Valor inválido')
	}

	return &Transacao{
		cliente_id: cliente_id
		valor: valor
		tipo: tipo.str()
		descricao: descricao
		realizada_em: time.now()
	}
}

@[inline]
pub fn Transacao.from_json(json_str string, cliente_id int) !&Transacao {
	json_obj := json2.fast_raw_decode(json_str)!.as_map()
	descricao := json_obj['descricao']!.str()
	tipo := TipoTransacao.from_str(json_obj['tipo']!.str())!
	valor := json_obj['valor']!.int()

	return Transacao.new(cliente_id, valor, tipo, descricao)
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

