-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- This script creates the external organized tables oeoh_oeol_wias and oeoh_oeol_wias_h
--
-- It expects that the .lst flat files holding the data for these tables be in virtual directory applptmp
-- Since usually $APPLPTMP is part of utl_file_dir initialization parameter in database, we an use that 
-- location for having the data flat files at.
-- =====================================================================================================

set echo on time on timing on 

-- 
-- Example
-- create or replace directory applptmp as '/ORACLE/apps/dev/temp';
--
rem prompt
rem prompt Please input the value of $APPLPTMP variable (AFTER making sure that its part of utl_file_dir rdbms parameter): 
rem prompt
define applptmp=&1
create or replace directory applptmp as '&applptmp';

drop table oeoh_oeol_wias;

prompt ---------------------------------------
prompt now create oeoh_oeol_wias
prompt ---------------------------------------

CREATE TABLE oeoh_oeol_wias
 (
     order_number  number(10),
     header_status varchar2(25),
     header_type   varchar2(10),
     header_id     number(15),
     header_begin_date varchar2(10),
     header_end_date varchar2(10),
     line_type   varchar2(10),
     line_id     number(15),
     line_status varchar2(25),
     line_begin_date varchar2(10),
     line_end_date varchar2(10),
     wias_impact   number(10)
) 
ORGANIZATION EXTERNAL
   (
         TYPE oracle_loader
         DEFAULT DIRECTORY applptmp
         ACCESS PARAMETERS 
         (
               RECORDS DELIMITED BY NEWLINE
               badfile     applptmp:'oeoh_oeol_wias.bad'
               discardfile applptmp:'oeoh_oeol_wias.dis'
               logfile     applptmp:'oeoh_oeol_wias.log'
               FIELDS TERMINATED BY whitespace
               REJECT ROWS WITH ALL NULL FIELDS
         )
         LOCATION ('oeoh_oeol_wias_open_closed.lst')
   )
PARALLEL 10
REJECT LIMIT UNLIMITED;

select count(1) from oeoh_oeol_wias 
where order_number is not null
  and header_status is not null
  and header_type is not null
  and header_id is not null
  and header_begin_date is not null
  and header_end_date is not null
  and line_type is not null
  and line_id is not null
  and line_status is not null
  and line_begin_date is not null
  and line_end_date is not null
  and wias_impact is not null;

prompt ---------------------------------------
prompt now create oeoh_oeol_wias_h
prompt ---------------------------------------

drop table oeoh_oeol_wias_h;

CREATE TABLE oeoh_oeol_wias_h
(
     order_number  number(10),
     header_status varchar2(25),
     header_type   varchar2(10),
     header_id     number(15),
     header_begin_date varchar2(10),
     header_end_date varchar2(10),
     line_type   varchar2(10),
     line_id     number(15),
     line_status varchar2(25),
     line_begin_date varchar2(10),
     line_end_date varchar2(10),
     wiash_impact   number(10)
) 
ORGANIZATION EXTERNAL
   (
         TYPE oracle_loader
         DEFAULT DIRECTORY applptmp
         ACCESS PARAMETERS 
         (
               RECORDS DELIMITED BY NEWLINE
               badfile     applptmp:'oeoh_oeol_wias_h.bad'
               discardfile applptmp:'oeoh_oeol_wias_h.dis'
               logfile     applptmp:'oeoh_oeol_wias_h.log'
               FIELDS TERMINATED BY whitespace
               REJECT ROWS WITH ALL NULL FIELDS
         )
         LOCATION ('oeoh_oeol_wias_h_open_closed.lst')
   )
PARALLEL 10
REJECT LIMIT UNLIMITED;

select count(1) from oeoh_oeol_wias_h 
where order_number is not null
  and header_status is not null
  and header_type is not null
  and header_id is not null
  and header_begin_date is not null
  and header_end_date is not null
  and line_type is not null
  and line_id is not null
  and line_status is not null
  and line_begin_date is not null
  and line_end_date is not null
  and wiash_impact is not null;

exit
/

