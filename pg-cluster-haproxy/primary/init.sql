-- Buat user replicator
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicatorpass';

-- Buat contoh tabel
CREATE TABLE IF NOT EXISTS test_table (
    id SERIAL PRIMARY KEY,
    name TEXT
);

INSERT INTO test_table (name) VALUES ('Hello from cluster primary');
