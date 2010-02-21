set feedback off
set serveroutput on
declare
 cursor c_session is
  select type, status from v$session;

 t_timestamp        number (10) := 0;
 t_system           number (10) := 0;
 t_active           number (10) := 0;
 t_inactive         number (10) := 0;

begin
 dbms_output.enable(650000);
 for r_session in c_session
 loop
  if r_session.type = 'BACKGROUND'
   then
     t_system := t_system + 1;
  else
     if r_session.status = 'ACTIVE'
      then
        t_active := t_active + 1;
     else
        t_inactive := t_inactive + 1;
     end if;
  end if;
 end loop;

 dbms_output.put_line('N:'||t_system||':'||t_active||':'||t_inactive);
end;
/
