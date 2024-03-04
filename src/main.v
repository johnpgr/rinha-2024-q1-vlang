module main

import vweb
import os
import time
import db.pg
import math
import json

const port = os.getenv_opt('PORT') or { '9999' }.int()
const db_name = os.getenv_opt('DB_NAME') or { panic('DB_NAME not set') }
const db_user = os.getenv_opt('DB_USER') or { panic('DB_USER not set') }
const db_pass = os.getenv_opt('DB_PASS') or { panic('DB_PASS not set') }
const db_host = os.getenv_opt('DB_HOST') or { panic('DB_HOST not set') }
const db_port = os.getenv_opt('DB_PORT') or { panic('DB_PORT not set') }.int()

fn pg_connect() pg.DB {
	return pg.connect(
		host: db_host
		port: db_port
		user: db_user
		password: db_pass
		dbname: db_name
	) or { panic(err) }
}

@[table: 'cliente']
pub struct Cliente {
pub mut:
	id     int    @[primary; sql: serial]
	nome   string
	limite int
	saldo  int
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

@[table: 'transacao']
pub struct Transacao {
pub mut:
	id           int       @[json: '-'; primary; sql: serial]
	cliente_id   int       @[json: '-'; required]
	valor        int       @[required]
	tipo         string    @[required]
	descricao    string    @[required]
	realizada_em time.Time @[required]
}

pub struct TransacaoRequest {
	valor     f32    @[required]
	tipo      string @[required]
	descricao string @[required]
}

@[inline]
pub fn (t TransacaoRequest) is_valid() bool {
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
pub fn (t TransacaoRequest) to_transacao(cliente_id int) Transacao {
	return Transacao{
		cliente_id: cliente_id
		valor: int(t.valor)
		tipo: t.tipo
		descricao: t.descricao
		realizada_em: fast_time_now()
	}
}

@[inline]
pub fn Transacao.from_req(json_str string, cliente_id int) !Transacao {
	mut t_req := json.decode(TransacaoRequest, json_str)!
	if !t_req.is_valid() {
		return error('Falha ao validar transação')
	}

	t := t_req.to_transacao(cliente_id)

	return t
}

@[inline]
pub fn (t Transacao) save(db pg.DB) ! {
	sql db {
		insert t into Transacao
	}!
}

@[direct_array_access; inline]
pub fn Cliente.get_extrato(db pg.DB, cliente_id int) !Extrato {
	clientes := sql db {
		select from Cliente where id == cliente_id limit 1
	}!

	if clientes.len == 0 {
		return error('Cliente não encontrado')
	}

	transacoes := sql db {
		select from Transacao where cliente_id == cliente_id order by id desc limit 10
	}!

	return Extrato{
		saldo: struct {
			total: clientes[0].saldo
			data_extrato: fast_time_now()
			limite: clientes[0].limite
		}
		ultimas_transacoes: transacoes
	}
}

@[direct_array_access; inline]
pub fn Cliente.efetuar_transacao(db pg.DB, cliente_id int, valor_transacao int) ?(int, int) {
	res := db.exec_param_many(r'
			UPDATE cliente
			SET saldo = saldo + $2
			WHERE
				id = $1
				AND $2 + saldo + limite >= 0
			RETURNING saldo, limite
	',
		[cliente_id.str(), valor_transacao.str()]) or { return none }

	if res.len == 0 {
		return none
	}

	saldo := res[0].vals[0]
	limite := res[0].vals[1]

	return saldo?.int(), limite?.int()
}

fn main() {
	app := &App{
		db_handle: vweb.database_pool(handler: pg_connect)
	}

	vweb.run_at(app, vweb.RunParams{
		host: '0.0.0.0'
		port: port
		family: .ip
	}) or { panic(err) }
}
