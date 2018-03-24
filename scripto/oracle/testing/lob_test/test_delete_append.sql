connect system/manager
SET SERVEROUTPUT ON;
exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;
exec dbms_output.put_line('AWR SNAP');
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate from dual;

connect reftech/reftech

declare
    tmp_blob blob default EMPTY_BLOB();
    tmp_bfile bfile:=null;
    dest_offset integer:=1;
    src_offset integer:=1;
begin
     select b_file into tmp_bfile from test_bfile;
     DBMS_LOB.OPEN (tmp_bfile, DBMS_LOB.FILE_READONLY);
     dbms_lob.createtemporary(tmp_blob, TRUE);
     DBMS_LOB.LOADBLOBFROMFILE(tmp_blob,tmp_bfile,DBMS_LOB.LOBMAXSIZE,dest_offset,src_offset);
     for i in 1..400 loop
          insert /*+ append */ into test values(i,tmp_blob);
          commit;
     end loop;
     DBMS_LOB.CLOSE(tmp_bfile);
end;
/

exec dbms_output.put_line('DELETE 1/3 OF THE ROWS IN OUR TEST TABLE ');
delete from test where (id/3) = trunc(id/3);
rem exec dbms_output.put_line('DELETE ALL OF THE ROWS IN OUR TEST TABLE ');
rem delete test;
rem COMMIT;

connect system/manager
SET SERVEROUTPUT ON;
exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;
exec dbms_output.put_line('AWR SNAP');
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate from dual;

quit;
/
