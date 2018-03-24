connect system/manager
SET SERVEROUTPUT ON;
exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;
exec dbms_output.put_line('AWR SNAP');
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate from dual;

connect reftech/reftech
drop table reftech.test;
drop table reftech.test_bfile;

SET SERVEROUTPUT ON;
column TBS_FULL format a30
set timing on

CREATE TABLE test ( ID NUMBER, PHOTO BLOB ) lob (PHOTO) store as BASICFILE ;
CREATE TABLE test_bfile ( B_FILE BFILE) ;

CREATE or REPLACE DIRECTORY test as '/tmp';

ALTER TABLE TEST MODIFY LOB (PHOTO) (PCTVERSION 0);

exec dbms_output.put_line('EXAMINE THE STORAGE');

SELECT Total.name "Tablespace Name", TO_CHAR(ROUND(100-(Free_space*100/total_space), 2)) TBS_full, round(total_space) "total_space(MB)", round(Free_space) "Free_space(MB)"
FROM
 ( select tablespace_name, sum(bytes/1024/1024) Free_Space
   from sys.dba_free_space
   group by tablespace_name
 ) Free,
 ( select b.name, sum(bytes/1024/1024) TOTAL_SPACE
   from sys.v_$datafile a, sys.v_$tablespace B
   where a.ts# = b.ts#
   group by b.name
 ) Total
WHERE Free.Tablespace_name = Total.name
  and Free.Tablespace_name = 'USERS';


exec dbms_output.put_line('LOAD THE DATA');

insert into test_bfile values ( bfilename('TEST','1.jpg'));

commit;

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
     for i in 1..4000 loop
          insert into test values(i,tmp_blob);
          commit;
     end loop;
     DBMS_LOB.CLOSE(tmp_bfile);
end;
/

exec dbms_output.put_line('EXAMINE THE STORAGE');

column segment_name format a30
set pagesiz 1000

select segment_name, sum(bytes) BYTES, count(*) EXTENTS
from user_extents
group by segment_name;


SELECT Total.name "Tablespace Name", TO_CHAR(ROUND(100-(Free_space*100/total_space), 2)) TBS_full, round(total_space) "total_space(MB)", round(Free_space) "Free_space(MB)"
FROM
 ( select tablespace_name, sum(bytes/1024/1024) Free_Space
   from sys.dba_free_space
   group by tablespace_name
 ) Free,
 ( select b.name, sum(bytes/1024/1024) TOTAL_SPACE
   from sys.v_$datafile a, sys.v_$tablespace B
   where a.ts# = b.ts#
   group by b.name
 ) Total
WHERE Free.Tablespace_name = Total.name
  and Free.Tablespace_name = 'USERS';



rem exec dbms_output.put_line('DELETE 1/3 OF THE ROWS IN OUR TEST TABLE ');
rem delete from test where (id/3) = trunc(id/3);
exec dbms_output.put_line('DELETE ALL OF THE ROWS IN OUR TEST TABLE ');
delete test;

COMMIT;

exec dbms_output.put_line('EXAMINE THE CHANGE IN STORAGE');

SELECT Total.name "Tablespace Name", TO_CHAR(ROUND(100-(Free_space*100/total_space), 2)) TBS_full, round(total_space) "total_space(MB)", round(Free_space) "Free_space(MB)"
FROM
 ( select tablespace_name, sum(bytes/1024/1024) Free_Space
   from sys.dba_free_space
   group by tablespace_name
 ) Free,
 ( select b.name, sum(bytes/1024/1024) TOTAL_SPACE
   from sys.v_$datafile a, sys.v_$tablespace B
   where a.ts# = b.ts#
   group by b.name
 ) Total
WHERE Free.Tablespace_name = Total.name
  and Free.Tablespace_name = 'USERS';




exec dbms_output.put_line('JUST LIKE WITH NON LOB TABLES ... THE LOB DOES NOT SHOW REDUCTION IN SPACE AFTER A DELETE');

exec dbms_output.put_line('SHRINK THE TABLE');

alter table test enable row movement;

alter table test shrink space cascade;


exec dbms_output.put_line('EXAMINE THE CHANGE IN STORAGE');

SELECT Total.name "Tablespace Name", TO_CHAR(ROUND(100-(Free_space*100/total_space), 2)) TBS_full, round(total_space) "total_space(MB)", round(Free_space) "Free_space(MB)"
FROM
 ( select tablespace_name, sum(bytes/1024/1024) Free_Space
   from sys.dba_free_space
   group by tablespace_name
 ) Free,
 ( select b.name, sum(bytes/1024/1024) TOTAL_SPACE
   from sys.v_$datafile a, sys.v_$tablespace B
   where a.ts# = b.ts#
   group by b.name
 ) Total
WHERE Free.Tablespace_name = Total.name
  and Free.Tablespace_name = 'USERS';


connect system/manager
SET SERVEROUTPUT ON;
exec DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT;
exec dbms_output.put_line('AWR SNAP');
alter session set NLS_DATE_FORMAT = "YYYY/MM/DD HH24:MI:SS";
select sysdate from dual;

