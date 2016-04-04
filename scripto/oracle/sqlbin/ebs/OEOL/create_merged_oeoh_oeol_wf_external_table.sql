-- =====================================================================================================
-- Created gverma - 22nd feb 2007
--
-- This script creates the external organized table merged_oeoh_oeol_wf
--
-- It expects that the .lst flat files holding the data for these tables be in virtual directory applptmp
-- Since usually $APPLPTMP is part of utl_file_dir initialization parameter in database, we an use that 
-- location for having the data flat files at.
-- =====================================================================================================

set echo on time on timing on 

drop table merged_oeoh_oeol_wf;

prompt ---------------------------------------
prompt now create merged_oeoh_oeol_wf
prompt ---------------------------------------

CREATE TABLE merged_oeoh_oeol_wf
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
     wias_impact   number(10),
     wiash_impact   number(10),
     line_rec_open_parent number(10),
     line_rec_open_children number(10)
) 
ORGANIZATION EXTERNAL
   (
         TYPE oracle_loader
         DEFAULT DIRECTORY applptmp
         ACCESS PARAMETERS 
         (
               RECORDS DELIMITED BY NEWLINE
               badfile     applptmp:'merge_oeoh_oeol_wf.bad'
               discardfile applptmp:'merge_oeoh_oeol_wf.dis'
               logfile     applptmp:'merge_oeoh_oeol_wf.log'
               FIELDS TERMINATED BY whitespace
               REJECT ROWS WITH ALL NULL FIELDS
         )
         LOCATION ('merge_oeoh_oeol_wf.lst')
   )
PARALLEL 10
REJECT LIMIT UNLIMITED;

select count(1) from merged_oeoh_oeol_wf 
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
  and wiash_impact is not null
  and wias_impact is not null
  and line_rec_open_parent is not null
  and line_rec_open_children is not null;

exit
/

