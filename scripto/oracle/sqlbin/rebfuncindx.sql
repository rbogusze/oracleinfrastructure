set serveroutput on
set linesize 300
set pagesize 100
accept ans char format 'A1' prompt 'Rebuild functional indexes with FUNCIDX_STATUS column equal DISABLED continue ? [y/n]'
declare
  Cursor c_indexes is (Select owner,index_name
        from dba_indexes where funcidx_status='DISABLED');
  r_index c_indexes%ROWTYPE;
  strLine varchar2(1024);
  selection varchar2(1) := upper(substr('&ans',1,1));
begin
  if selection = 'Y' THEN
    FOR r_index in c_indexes LOOP
      strLine := 'Alter index ' || r_index.owner || '.' || r_index.index_name || ' rebuild online';
      dbms_output.put_line(strLine);
      Execute immediate  strLine;
    END LOOP;
  END IF;
end;
/
exit
