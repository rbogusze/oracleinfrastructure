set linesize 200
set pagesize 50
select username, account_status, lock_date, expiry_date, profile from dba_users where account_status != 'OPEN';
