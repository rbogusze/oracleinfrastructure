Rem
Rem $Header: /CVS/cvsadmin/cvsrepository/admin/projects/musas1x/sp10g/spreport.sql,v 1.1 2011/07/27 20:12:52 remikcvs Exp $
Rem
Rem spreport.sql
Rem
Rem  Copyright (c) Oracle Corporation 1999, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      spreport.sql
Rem
Rem    DESCRIPTION
Rem      This script defaults the dbid and instance number to that of the
Rem      current instance connected-to, then calls sprepins.sql to produce
Rem      the standard Statspack report.
Rem
Rem    NOTES
Rem      Usually run as the STATSPACK owner, PERFSTAT
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdialeri    03/20/01 - 1747076
Rem    cdialeri    03/12/01 - Created

--
-- Get the current database/instance information - this will be used 
-- later in the report along with bid, eid to lookup snapshots

column inst_num  heading "Inst Num"  new_value inst_num  format 99999;
column inst_name heading "Instance"  new_value inst_name format a12;
column db_name   heading "DB Name"   new_value db_name   format a12;
column dbid      heading "DB Id"     new_value dbid      format 9999999999 just c;

prompt
prompt Current Instance
prompt ~~~~~~~~~~~~~~~~

select d.dbid            dbid
     , d.name            db_name
     , i.instance_number inst_num
     , i.instance_name   inst_name
  from v$database d,
       v$instance i;

@@sprepins

--
-- End of file
