DROP KEYSPACE IF EXISTS remik1;
CREATE KEYSPACE remik1 WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
use remik1;
CREATE TABLE table1 (
    id int PRIMARY KEY,
    name text, 
    temperature double
);
INSERT INTO table1 (id, name, temperature) values (0, 'Ala', 123); 
INSERT INTO table1 (id, name, temperature) values (1, 'Ola', 321); 
