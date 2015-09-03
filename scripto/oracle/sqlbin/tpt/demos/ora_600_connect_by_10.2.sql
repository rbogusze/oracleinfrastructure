alter session set "_old_connect_by_enabled"=true;
select 1 from dual connect by level < 2;

