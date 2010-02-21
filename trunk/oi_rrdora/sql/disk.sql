set feedback off
set serveroutput on
declare

 t_total            dba_data_files.bytes%TYPE := 0;
 t_free             dba_free_space.bytes%TYPE := 0;
 t_used             dba_free_space.bytes%TYPE := 0;

begin
 dbms_output.enable(650000);
 select sum(bytes) into t_total from dba_data_files;
 select sum(bytes) into t_free  from dba_free_space;
 t_used := t_total - t_free;
 dbms_output.put_line('N:'||t_used||':'||t_free);
end;
/
