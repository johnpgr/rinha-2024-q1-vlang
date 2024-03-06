module main

import db.pg
import time
import json

pub struct Cliente {
pub mut:
	id                 int
	nome               string
	limite             int
	saldo              int
	ultimas_transacoes []Transacao
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

@[direct_array_access; inline]
pub fn Cliente.find(db pg.DB, cliente_id int) !Cliente {
	res := db.exec_param(r'SELECT * FROM cliente WHERE id = $1', cliente_id.str())!

	if res.len == 0 {
		return error('Cliente não encontrado')
	}

	for row in res {
		mut cliente := Cliente{}

		id := row.vals[0] or { return error('Cliente não encontrado') }
		nome := row.vals[1] or { return error('Cliente não encontrado') }
		limite := row.vals[2] or { return error('Cliente não encontrado') }
		saldo := row.vals[3] or { return error('Cliente não encontrado') }
		ultimas_transacoes := row.vals[4] or { return error('Cliente não encontrado') }

		cliente.id = (id as string).int()
		cliente.nome = nome as string
		cliente.limite = (limite as string).int()
		cliente.saldo = (saldo as string).int()
		cliente.ultimas_transacoes = json.decode([]Transacao, ultimas_transacoes as string) or {
			return error('Falha ao buscar cliente')
		}

		return cliente
	}

	return error('Falha ao buscar cliente')
}

@[direct_array_access; inline]
pub fn Cliente.efetuar_transacao(db pg.DB, cliente_id int, transacao Transacao) !TransacaoResponse {
	transacao_json := fast_json_encode(transacao) or {
		return error('Falha ao efetuar transação')
	}

	res := db.exec_param2(r'SELECT add_transacao($1, $2)', cliente_id.str(), transacao_json)!

	if res.len == 0 {
		return error('Falha ao efetuar transação')
	}

	for row in res {
		raw := row.vals[0] or { return error('Falha ao efetuar transação') }

		val := json.decode(TransacaoResponse, raw as string) or {
			return error('Saldo insuficiente')
		}
		return val
	}

	return error('Falha ao efetuar transação')
}
