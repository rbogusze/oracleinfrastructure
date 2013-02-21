Rem
Rem $Header: /CVS/cvsadmin/cvsrepository/admin/projects/musas1x/sp11g/sprepsql.sql,v 1.1 2011/07/26 13:20:09 remikcvs Exp $
Rem
Rem sprepsql.sql
Rem
Rem Copyright (c) 2000, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      sprepsql.sql - StatsPack REPort SQL
Rem
Rem    DESCRIPTION
Rem      This script defaults the dbid and instance number to that of the
Rem      current instance connected-to, then calls sprsqins.sql to produce
Rem      the standard Statspack SQL report.
Rem
Rem    NOTES
Rem      Usually run as the PERFSTAT user
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdialeri    10/09/02 - Created
Rem

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

@@sprsqins

--
-- End of file
