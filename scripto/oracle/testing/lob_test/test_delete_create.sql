connect reftech/reftech
drop table reftech.test;
drop table reftech.test_bfile;
commit;

SET SERVEROUTPUT ON;
column TBS_FULL format a30
set timing on

CREATE TABLE test ( ID NUMBER, PHOTO BLOB ) lob (PHOTO) store as BASICFILE ;
CREATE TABLE test_bfile ( B_FILE BFILE) ;

CREATE or REPLACE DIRECTORY test as '/tmp';

ALTER TABLE TEST MODIFY LOB (PHOTO) (PCTVERSION 0);

exec dbms_output.put_line('LOAD THE DATA');

insert into test_bfile values ( bfilename('TEST','1.jpg'));
commit;

