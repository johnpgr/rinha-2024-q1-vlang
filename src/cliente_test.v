module main

// Uma transação de débito nunca pode deixar o saldo do cliente menor que seu limite disponível.
// Por exemplo, um cliente com limite de 1000 (R$ 10) nunca deverá ter o saldo menor que -1000 (R$ -10).
fn test_cliente_transacao_debito() {
	mut cliente := Cliente.new(10000, 0)

	transacao := Transacao.new(cliente.id, 1000, .debito, 'Test')
	cliente.efetuar_transacao(transacao) or {
		assert false, 'Esta transação não deve falhar'
		return
	}
	assert cliente.saldo == -1000

	transacao2 := Transacao.new(cliente.id, 9000, .debito, 'Test2')
	cliente.efetuar_transacao(transacao2) or {
		assert false, 'Esta transação não deve falhar'
		return
	}
	assert cliente.saldo == -10000

	transacao3 := Transacao.new(cliente.id, 1000, .debito, 'Test3')
	cliente.efetuar_transacao(transacao3) or {
		assert true, 'Esta transação deve falhar'
		return
	}

	assert false, 'Esta linha de código não deve ser atingida'
}

fn test_cliente_transacao_credito() {
	mut cliente := Cliente.new(10000, 0)

	transacao := Transacao.new(cliente.id, 1000, .credito, 'Test')
	cliente.efetuar_transacao(transacao) or {
		assert false, 'Esta transação não deve falhar'
		return
	}
	assert cliente.limite == 9000, 'O limite do cliente deverá ser 9000'

	transacao2 := Transacao.new(cliente.id, 9000, .credito, 'Test2')
	cliente.efetuar_transacao(transacao2) or {
		assert false, 'Esta transação não deve falhar'
		return
	}
	assert cliente.limite == 0, 'O limite do cliente deverá ser 0'

	transacao3 := Transacao.new(cliente.id, 1000, .credito, 'Test3')
	cliente.efetuar_transacao(transacao3) or {
		assert true, 'Esta transação deve falhar'
		return
	}
	assert false, 'Esta linha de código não deve ser atingida'
}

fn test_cliente_extrato(){
	mut cliente := Cliente.new(10000,0)

	transacao := Transacao.new(cliente.id, 1000, .credito, 'Test')
	cliente.efetuar_transacao(transacao) or {
		assert false, 'Esta transação não deve falhar'
		return
	}
	assert cliente.transacoes.len == 1, 'O cliente deverá ter 1 transação'
}
