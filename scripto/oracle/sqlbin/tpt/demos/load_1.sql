prompt starting demo_load_1...
set termout off
insert into t values(0);
commit;
delete t where a=0;
set termout on
prompt done. run demo_load_2 now in another session...
