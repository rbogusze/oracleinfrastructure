set feedback off
set serveroutput on
declare
 cursor c_cpu is
  select name,value  from v$sysstat
  where name in ('CPU used by this session','parse time cpu','recursive cpu usage');

 t_total            v$sysstat.value%TYPE := 0;
 t_other            v$sysstat.value%TYPE := 0;
 t_parse            v$sysstat.value%TYPE := 0;
 t_recursive        v$sysstat.value%TYPE := 0;

begin
 dbms_output.enable(650000);
 for r_cpu in c_cpu
 loop
  if r_cpu.name = 'CPU used by this session'
   then
     t_total := r_cpu.value;
  else
     if r_cpu.name = 'parse time cpu'
      then
        t_parse := r_cpu.value;
     else
        t_recursive := r_cpu.value;
     end if;
  end if;
 end loop;

 t_other := greatest(t_total - t_parse - t_recursive,0);

 dbms_output.put_line('N:'||t_parse||':'||t_recursive||':'||t_other);
end;
/
