PRAGMA journal_mode = WAL;
PRAGMA threads = 4;
PRAGMA busy_timeout = 30000;
PRAGMA temp_store = MEMORY;
PRAGMA cache_size = 10000;
PRAGMA auto_vacuum = FULL;
PRAGMA automatic_indexing = TRUE;
PRAGMA count_changes = FALSE;
PRAGMA encoding = "UTF-8";
PRAGMA ignore_check_constraints = TRUE;
PRAGMA incremental_vacuum = 0;
PRAGMA legacy_file_format = FALSE;
PRAGMA optimize = On;
PRAGMA synchronous = NORMAL;

CREATE TABLE IF NOT EXISTS cliente(
	id INTEGER PRIMARY KEY,
	nome TEXT NOT NULL,
	limite INTEGER NOT NULL,
	saldo INTEGER DEFAULT 0
);

CREATE UNLOGGED TABLE IF NOT EXISTS transacao(
	id INTEGER PRIMARY KEY,
	cliente_id INTEGER NOT NULL,
	valor INTEGER NOT NULL,
	tipo CHAR(1) NOT NULL,
	descricao VARCHAR(10) NOT NULL,
	realizada_em TIMESTAMP NOT NULL,
);

DO $$
BEGIN
	INSERT INTO clientes (nome, limite) VALUES
	('o barato sai caro', 1000 * 100),
	('zan corp ltda', 800 * 100),
	('les cruders', 10000 * 100),
	('padaria joia de cocaia', 100000 * 100),
	('kid mais', 5000 * 100);
END;
$$;
