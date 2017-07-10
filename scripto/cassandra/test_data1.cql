DROP KEYSPACE IF EXISTS remik1;
CREATE KEYSPACE remik1 WITH REPLICATION = { 'class' : 'SimpleStrategy', 'replication_factor' : 1 };
use remik1;
CREATE TABLE weather_station (
    id text PRIMARY KEY,
    name text, 
    temperature double
);
