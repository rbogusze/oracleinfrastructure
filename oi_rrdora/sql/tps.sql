set feedback off
set serveroutput on
declare
 cursor c_tpm is
  select name,value from v$sysstat
  where name in ('user commits','user rollbacks');

 t_commits            v$sysstat.value%TYPE := 0;
 t_rollbacks            v$sysstat.value%TYPE := 0;
 t_tpm            v$sysstat.value%TYPE := 0;
 t_writes           v$sysstat.value%TYPE := 0;
 t_redos            v$sysstat.value%TYPE := 0;

begin
 dbms_output.enable(650000);
 for r_tpm in c_tpm
 loop
  if r_tpm.name = 'user commits'
   then
     t_tpm := r_tpm.value;
  else
     if r_tpm.name = 'user rollbacks'
      then
        t_tpm := t_tpm + r_tpm.value;
     end if;
  end if;
 end loop;

 dbms_output.put_line('N:'||t_tpm);
end;
/
