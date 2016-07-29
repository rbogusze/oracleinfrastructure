alter session set nls_date_format = 'YYYY-MM-DD HH24:MI:SS';

 
select count(*) from FND_LOGIN_RESP_FORMS;
select count(*) from FND_LOGIN_RESPONSIBILITIES;
select count(*) from FND_LOGINS;
select count(*) from FND_UNSUCCESSFUL_LOGINS;

select round(sum(bytes)/1024/1024) SIZE_MB from dba_segments where segment_name = 'FND_LOGIN_RESP_FORMS';
select round(sum(bytes)/1024/1024) SIZE_MB from dba_segments where segment_name = 'FND_LOGIN_RESPONSIBILITIES';
select round(sum(bytes)/1024/1024) SIZE_MB from dba_segments where segment_name = 'FND_LOGINS';
select round(sum(bytes)/1024/1024) SIZE_MB from dba_segments where segment_name = 'FND_UNSUCCESSFUL_LOGINS';

ALTER TABLE APPLSYS.FND_LOGIN_RESPONSIBILITIES ENABLE ROW MOVEMENT; 
ALTER TABLE APPLSYS.FND_LOGIN_RESPONSIBILITIES SHRINK SPACE CASCADE;
ALTER TABLE APPLSYS.FND_LOGIN_RESPONSIBILITIES DISABLE ROW MOVEMENT;

ALTER TABLE APPLSYS.FND_LOGIN_RESP_FORMS ENABLE ROW MOVEMENT; 
ALTER TABLE APPLSYS.FND_LOGIN_RESP_FORMS SHRINK SPACE CASCADE;
ALTER TABLE APPLSYS.FND_LOGIN_RESP_FORMS DISABLE ROW MOVEMENT;

ALTER TABLE APPLSYS.FND_LOGINS ENABLE ROW MOVEMENT; 
ALTER TABLE APPLSYS.FND_LOGINS SHRINK SPACE CASCADE;
ALTER TABLE APPLSYS.FND_LOGINS DISABLE ROW MOVEMENT;

ALTER TABLE APPLSYS.FND_UNSUCCESSFUL_LOGINS ENABLE ROW MOVEMENT; 
ALTER TABLE APPLSYS.FND_UNSUCCESSFUL_LOGINS SHRINK SPACE CASCADE;
ALTER TABLE APPLSYS.FND_UNSUCCESSFUL_LOGINS DISABLE ROW MOVEMENT;


select * from FND_LOGINS order by start_time desc;

SELECT name,      position ,      datatype_string ,      was_captured,      value_string  FROM   v$sql_bind_capture  WHERE  sql_id = '32czjgd3hu7zf';




insert into FND_LOGINS (select * from FND_LOGINS);
insert into FND_LOGINS (select FND_LOGINS_S.nextval,user_id,start_time, end_time, pid, spid, terminal_id, login_name, session_number, submitted_login_id, serial#, process_spid, login_type, security_group_id  from FND_LOGINS);

select * from all_sequences where sequence_name like 'FND_LOGI%';

-- 6095880, 6095881


-- 2015.08.26 itestc1 'Purge Signon Audit Data' was run today and reorg done, performance is fine now but the query still uses FTS
SELECT name,      position ,      datatype_string ,      was_captured,      value_string  FROM   v$sql_bind_capture  WHERE  sql_id = '32czjgd3hu7zf';
--:B1	1	NUMBER	YES	1234

select plan_table_output from table(dbms_xplan.display_cursor('32czjgd3hu7zf',null,'basic'));
/*
EXPLAINED SQL STATEMENT:
------------------------
SELECT C_LOG.ROWID FROM FND_LOGINS C_LOG WHERE C_LOG.SPID = :B1 AND 
END_TIME IS NULL FOR UPDATE SKIP LOCKED
 
Plan hash value: 2051340730
 
-----------------------------------------
| Id  | Operation          | Name       |
-----------------------------------------
|   0 | SELECT STATEMENT   |            |
|   1 |  FOR UPDATE        |            |
|   2 |   TABLE ACCESS FULL| FND_LOGINS |
-----------------------------------------
*/

-- Searching shared pool in sun4 in search of the similar SQL
select * from v$sqlarea
where sql_text like '%FND_LOGINS%';

/*
I can not find any. Hm. 

But he is increasing this table.
6095924
6095925

I just see plain insert:
INSERT INTO FND_LOGINS (LOGIN_ID, USER_ID, START_TIME, TERMINAL_ID, LOGIN_NAME, PID, SPID, SESSION_NUMBER, SERIAL#, PROCESS_SPID, LOGIN_TYPE) VALUES(:B9 , :B8 , SYSDATE, :B7 , :B6 , :B5 , :B4 , :B3 , :B2 , :B1 , 'FORM')

No funny select for update.
*/
select count(*) from FND_LOGINS;







