module main

import time
import json
import math
import db.pg

@[table: 'transacao']
pub struct Transacao {
pub mut:
	cliente_id   int
	valor        int       @[required]
	tipo         string    @[required; sql_type: 'CHAR(1)']
	descricao    string    @[required]
	realizada_em time.Time @[required]
}

@[inline]
pub fn (t &Transacao) to_response() &TransacaoResponse {
	return &TransacaoResponse{
		valor: t.valor
		tipo: t.tipo
		descricao: t.descricao
		realizada_em: t.realizada_em
	}
}

@[inline]
pub fn (t []Transacao) to_response() []TransacaoResponse {
	return t.map(*it.to_response())
}

pub struct TransacaoRequest {
	valor     f64    @[required]
	tipo      string @[required]
	descricao string @[required]
}

pub struct TransacaoResponse {
	valor        int       @[required]
	tipo         string    @[required]
	descricao    string    @[required]
	realizada_em time.Time @[required]
}

@[inline]
pub fn (t &TransacaoRequest) is_valid() bool {
	if t.descricao.is_blank() || t.descricao.len > 10 {
		return false
	}

	if t.valor < 0 || math.fmod(t.valor, 1) != 0 {
		return false
	}

	return match t.tipo {
		'd' {
			true
		}
		'c' {
			true
		}
		else {
			false
		}
	}
}

@[inline]
pub fn (t &TransacaoRequest) to_transacao(cliente_id int) &Transacao {
	return &Transacao{
		cliente_id: cliente_id
		valor: int(t.valor)
		tipo: t.tipo
		descricao: t.descricao
		realizada_em: fast_time_now()
	}
}

@[inline]
pub fn Transacao.from_json(json_str string, cliente_id int) !&Transacao {
	mut t_req := json.decode(TransacaoRequest, json_str)!
	if !t_req.is_valid() {
		return error('Falha ao validar transação')
	}

	t := t_req.to_transacao(cliente_id)

	return t
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
