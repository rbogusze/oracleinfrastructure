set feedback off
set serveroutput on
declare
 cursor c_phys_io is
  select name,value  from v$sysstat
  where name in ('physical reads direct', 'physical writes','redo entries');

 t_reads            v$sysstat.value%TYPE := 0;
 t_writes           v$sysstat.value%TYPE := 0;
 t_redos            v$sysstat.value%TYPE := 0;

begin
 dbms_output.enable(650000);
 for r_phys_io in c_phys_io
 loop
  if r_phys_io.name = 'physical reads direct'
   then
     t_reads := r_phys_io.value;
  else
     if r_phys_io.name = 'physical writes'
      then
        t_writes := r_phys_io.value;
     else
        t_redos := r_phys_io.value;
     end if;
  end if;
 end loop;

 dbms_output.put_line('N:'||t_reads||':'||t_writes||':'||t_redos);
end;
/
