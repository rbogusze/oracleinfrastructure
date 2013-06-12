prompt This script creates the perf and perf2 big tables
connect scott/tiger
create table perf tablespace users
  as select * from (
  select * from dba_objects union all
  select * from dba_objects union all
  select * from dba_objects union all
  select * from dba_objects union all
  select * from dba_objects union all
  select * from dba_objects
);

create table perf2 tablespace users
  as select * from (
  select * from perf union all
  select * from perf union all
  select * from perf union all
  select * from perf union all
  select * from perf union all
  select * from perf union all
  select * from perf union all
  select * from perf
);
