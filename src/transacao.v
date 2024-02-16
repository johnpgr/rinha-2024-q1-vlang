module main

import time
import orm

enum TipoTransacao {
	debito
	credito
}

@[table: 'transacao']
struct Transacao {
	cliente_id   int
	valor        u64
	tipo         TipoTransacao
	descricao    string
	realizada_em time.Time
}

fn Transacao.new(cliente_id int, valor u64, tipo TipoTransacao, descricao string) &Transacao {
	t := Transacao{
		cliente_id: cliente_id
		valor: valor
		tipo: tipo
		descricao: descricao
		realizada_em: time.now()
	}

	return &t
}

fn (t &Transacao) save(conn orm.Connection) ! {
	sql conn {
		insert t into Transacao
	}!
}
