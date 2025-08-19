# PostgreSQL Replication & HA — Docker Examples

# Easy Test

Tiga setup:

1. `pg-replication-basic/` → Primary + Replica (belajar/testing, failover manual)
2. `pg-cluster-haproxy/` → Primary + Replica + HAProxy (1 endpoint, failover manual)
3. `pg-ha/` → Patroni + etcd + HAProxy (auto-failover, read/write split)

---

## Cara Jalankan

### 1) Basic

```bash
cd pg-replication-basic
docker compose up -d

# Test insert ke primary
docker exec -it pg_primary psql -U postgres -d mydb -c "INSERT INTO test_table(name) VALUES ('hello');"

# Cek data di replica
docker exec -it pg_replica psql -U postgres -d mydb -c "TABLE test_table;"
```

---

### 2) Cluster + HAProxy

```bash
cd pg-cluster-haproxy
docker compose up -d

# Insert lewat HAProxy (port 5000)
PGPASSWORD=postgres psql -h localhost -p 5000 -U postgres -d mydb -c "INSERT INTO test_table(name) VALUES ('from haproxy');"

# Cek data di replica langsung
docker exec -it pg_replica1 psql -U postgres -d mydb -c "TABLE test_table;"
```

> Failover manual: promote replica jika primary mati

```bash
docker exec -it pg_replica1 psql -U postgres -d mydb -c "SELECT pg_promote();"
```

---

### 3) HA dengan Patroni

```bash
cd pg-ha
docker compose up -d

# Insert ke leader via HAProxy (port 5000 = write)
PGPASSWORD=postgres psql -h localhost -p 5000 -U postgres -d postgres -c "INSERT INTO test_table(name) VALUES ('from patroni leader');"

# Baca dari replica (port 5001 = read pool)
PGPASSWORD=postgres psql -h localhost -p 5001 -U postgres -d postgres -c "TABLE test_table;"
```

> Test failover otomatis: stop leader

```bash
docker stop patroni1
```

Patroni otomatis promote node lain → HAProxy tetap arahkan backend ke leader baru di port `5000`.

---

## Endpoint

- **Basic**

  - Primary → `localhost:5432`
  - Replica → `localhost:5433`

- **Cluster HAProxy**

  - Write → `localhost:5000`

- **Patroni HA**

  - Write (leader) → `localhost:5000`
  - Read (replica pool) → `localhost:5001`
  - HAProxy stats → [http://localhost:8404](http://localhost:8404)
