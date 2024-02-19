module main

import time
import json
import orm

pub enum TipoTransacao {
	debito
	credito
}

@[inline]
pub fn (t TipoTransacao) str() string {
	match t {
		.debito { return 'd' }
		.credito { return 'c' }
	}
}

@[inline]
pub fn TipoTransacao.from_str(s string) !TipoTransacao {
	match s {
		'd' { return .debito }
		'c' { return .credito }
		else { return error('Tipo de transação inválido') }
	}
}

@[table: 'transacao']
pub struct Transacao {
	cliente_id   int
	valor        int
	tipo         TipoTransacao @[sql_type: 'SMALLINT']
	descricao    string
	realizada_em time.Time
}

@[inline]
pub fn Transacao.new(cliente_id int, valor int, tipo TipoTransacao, descricao string) &Transacao {
	t := Transacao{
		cliente_id: cliente_id
		valor: valor
		tipo: tipo
		descricao: descricao
		realizada_em: time.now()
	}

	return &t
}

@[inline]
pub fn Transacao.find_many(conn orm.Connection, cliente_id int, limit int) ![]Transacao {
	return sql conn {
		select from Transacao where cliente_id == cliente_id order by realizada_em desc limit limit
	}!
}

@[inline]
pub fn (t &Transacao) save(conn orm.Connection) ! {
	sql conn {
		insert t into Transacao
	}!
}

pub struct TransacaoRequest {
pub mut:
	valor     int    @[required]
	tipo      string @[required]
	descricao string @[required]
}

@[inline]
pub fn TransacaoRequest.from_json(data string) !&TransacaoRequest {
	transacao := json.decode(TransacaoRequest, data) or { return error(err.msg()) }
	return &transacao
}

@[inline]
pub fn (mut t TransacaoRequest) to_transacao(cliente_id int) !&Transacao {
	tipo_transacao := TipoTransacao.from_str(t.tipo) or { return error(err.msg()) }

	return Transacao.new(cliente_id, t.valor, tipo_transacao, t.descricao)
}

pub struct TransacaoResponse {
pub mut:
	limite int
	saldo  int
}

@[inline]
pub fn (app &App) handle_transacao(body string, cliente_id int) &Response {
	mut req := TransacaoRequest.from_json(body) or { return Response.bad_request() }

	mut cliente := Cliente.find(app.db, cliente_id) or { return Response.not_found() }
	transacao := req.to_transacao(cliente.id) or { return Response.bad_request() }
	cliente.efetuar_transacao(transacao) or { return Response.unprocessable() }
	cliente.save(app.db) or { return Response.internal_error() }
	transacao.save(app.db) or { return Response.internal_error() }

	return Response.json(TransacaoResponse{
		limite: cliente.limite
		saldo: cliente.saldo
	})
}
