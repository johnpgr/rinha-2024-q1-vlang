CREATE UNLOGGED TABLE IF NOT EXISTS "cliente" (
	id SERIAL PRIMARY KEY,
	limite INTEGER NOT NULL
);

CREATE UNLOGGED TABLE IF NOT EXISTS "saldo" (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	CONSTRAINT fk_cliente_saldo_id FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

CREATE UNLOGGED TABLE IF NOT EXISTS "transacao" (
	id SERIAL PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL,
	CONSTRAINT fk_cliente_transacao_id FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

DO $$
BEGIN
	INSERT INTO cliente (limite)
	VALUES
		(100000),
		(80000),
		(1000000),
		(10000000),
		(500000);

	INSERT INTO saldo (cliente_id, valor)
		SELECT id, 0 FROM cliente;
END;
$$;
