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
	tipo SMALLINT NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL DEFAULT NOW(),
	CONSTRAINT fk_cliente_transacao_id FOREIGN KEY (cliente_id) REFERENCES cliente(id)
);

DO $$
BEGIN
	INSERT INTO cliente (limite,saldo)
	VALUES
		(100000, 0),
		(80000, 0),
		(1000000, 0),
		(10000000, 0),
		(500000, 0);

	INSERT INTO saldo (cliente_id, valor)
		SELECT id, 0 FROM cliente;
END $$
