CREATE TABLE IF NOT EXISTS "cliente" (
	id SERIAL PRIMARY KEY,
	limite INTEGER NOT NULL,
	saldo INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS "transacao" (
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo SMALLINT NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_transacao_cliente ON transacao (cliente_id, realizada_em);

DO $$
BEGIN
	INSERT INTO cliente (limite,saldo)
	VALUES
		(100000, 0),
		(80000, 0),
		(1000000, 0),
		(10000000, 0),
		(500000, 0);
END $$
