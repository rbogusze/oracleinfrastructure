--------------------------------------------------------------------------------
--
-- Author:	Tanel Poder
-- Copyright:	(c) http://www.tanelpoder.com
-- 
-- Notes:	This software is provided AS IS and doesn't guarantee anything
-- 		Proofread before you execute it!
--
--------------------------------------------------------------------------------

define spuser=PERFSTAT
define spconn=""

accept spuser default &spuser prompt "Specify the schema where SAWR and SESSPACK are installed [&spuser]: "
accept sppassword prompt "Specify the password for &spuser user: " hide
accept spconn prompt "Enter connect string PREFIXED WITH @ if connecting to remote database [&spconn]: "

-- @@unprepare_user

connect &spuser/&sppassword&spconn

prompt Uninstalling schema...


@@drop_sesspack_packages.sql
@@drop_sesspack_schema.sql

prompt Schema uninstalled.
prompt 


prompt Uninstallation completed.
prompt Currently connected as &spuser&spconn....
prompt
