CREATE KEYSPACE remik2 WITH replication = {'class': 'SimpleStrategy', 'replication_factor': '3'}  AND durable_writes = true;
CREATE TABLE remik2.table1 (     id int PRIMARY KEY,     name text,     temperature double );
CREATE TABLE remik2.table2 (     id int PRIMARY KEY,     name text,     temperature double );
INSERT INTO remik2.table1 (id, name, temperature) values (0, 'Ala', 123);
INSERT INTO remik2.table1 (id, name, temperature) values (1, 'Ola', 456);
CREATE INDEX table1_id_name on remik2.table1 (name);
CREATE MATERIALIZED VIEW remik2.dailyhigh AS SELECT temperature, id, name FROM remik2.table1  where temperature is not null and id is not null and name is not null primary key (temperature, id) WITH CLUSTERING ORDER BY (temperature desc);
