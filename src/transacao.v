module main

import math
import json

pub struct Transacao {
pub mut:
	valor        int    @[required]
	tipo         string @[required]
	descricao    string @[required]
	realizada_em string @[required]
}

pub struct TransacaoRequest {
	valor     f32    @[required]
	tipo      string @[required]
	descricao string @[required]
}

pub struct TransacaoResponse {
	saldo  int @[required]
	limite int @[required]
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
pub fn (t TransacaoRequest) to_transacao() Transacao {
	return Transacao{
		valor: int(t.valor)
		tipo: t.tipo
		descricao: t.descricao
		realizada_em: fast_time_now().format_rfc3339()
	}
}

@[inline]
pub fn Transacao.from_json(json_str string) !Transacao {
	mut t_req := json.decode(TransacaoRequest, json_str)!
	if !t_req.is_valid() {
		return error('Falha ao validar transação')
	}

	t := t_req.to_transacao()

	return t
}
