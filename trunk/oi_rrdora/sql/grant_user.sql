/* Script for granting the user RRDORA enough access 
   Run it as user SYS or INTERNAL */
grant create session            to RRDORA;
grant select on dba_data_files  to RRDORA;
grant select on dba_free_space  to RRDORA;
grant select on v_$sysstat      to RRDORA;
grant select on v_$sysstat      to RRDORA;
grant select on v_$session      to RRDORA;
grant select on v_$system_event to RRDORA;
grant select on v_$parameter    to RRDORA;
grant select on v_$database     to RRDORA;
grant select on v_$license      to RRDORA;
grant select on v_$datafile	to RRDORA;
grant select on v_$tablespace	to RRDORA;
ALTER USER "RRDORA" DEFAULT TABLESPACE "USERS" TEMPORARY TABLESPACE "TEMP";
