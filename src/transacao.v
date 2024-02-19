module main

import time
import x.json2
import orm

pub enum TipoTransacao {
	debito
	credito
}

pub fn (t TipoTransacao) json_str() string {
	match t {
		.debito { return '"d"' }
		.credito { return '"c"' }
	}
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
	cliente_id int
pub mut:
	valor        int
	tipo         TipoTransacao @[sql_type: 'SMALLINT']
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
		tipo: tipo
		descricao: descricao
		realizada_em: time.now()
	}
}

@[inline]
pub fn Transacao.from_json(json_str string, cliente_id int) !&Transacao {
	json_obj := json2.raw_decode(json_str)!.as_map()
	descricao := json_obj['descricao']!.str()
	tipo := TipoTransacao.from_str(json_obj['tipo']!.str())!
	valor := json_obj['valor']!.int()

	return Transacao.new(cliente_id, valor, tipo, descricao)
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

@[inline]
pub fn (app &App) handle_transacao(body string, cliente_id int) &Response {
	transacao := Transacao.from_json(body, cliente_id) or {
		debug('[BAD_REQUEST] ${err.msg()} ${body}')
		return Response.bad_request()
	}
	mut cliente := Cliente.find(app.db, cliente_id) or {
		debug('[NOT_FOUND] ${err.msg()} ${body}')
		return Response.not_found()
	}
	cliente.efetuar_transacao(transacao) or {
		debug('[UNPROCESSABLE] ${err.msg()} ${body}')
		return Response.unprocessable()
	}
	cliente.save(app.db) or {
		debug('[INTERNAL_SERVER_ERROR] ${err.msg()} ${body}')
		return Response.internal_error()
	}
	transacao.save(app.db) or {
		debug('[INTERNAL_SERVER_ERROR]${err.msg()} ${body}')
		return Response.internal_error()
	}

	return Response.json({
		'limite': cliente.limite
		'saldo':  cliente.saldo
	})
}
