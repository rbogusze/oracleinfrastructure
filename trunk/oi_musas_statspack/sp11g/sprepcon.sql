Rem
Rem $Header: /CVS/cvsadmin/cvsrepository/admin/projects/musas1x/sp11g/sprepcon.sql,v 1.1 2011/07/26 13:20:09 remikcvs Exp $
Rem
Rem sprepcon.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sprepcon.sql - StatsPack REPort CONfiguration
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file which allows configuration of certain
Rem      aspects of the instance report
Rem
Rem    NOTES
Rem      To change the default settings, this file should be copied by
Rem      the user, then modified with the desired settings
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdgreen     03/02/05 - 10gR2 misc 
Rem    cdgreen     01/19/05 - Undostat threshold
Rem    cdgreen     07/30/04 - sp_10_r2 
Rem    vbarrier    02/12/04 - 3412853
Rem    cdialeri    10/14/03 - 10g - streams - rvenkate
Rem    cdialeri    10/07/03 - cdialeri_sp_10_f3 
Rem    cdialeri    08/06/03 - Created
Rem

Rem     -------------           Beginning of                -----------
Rem     ------------- Customer Configurable Report Settings -----------

--
-- Snapshot related report settings

-- The default number of days of snapshots to list when displaying the
-- list of snapshots to choose the begin and end snapshot Ids from.
--
--   List all snapshots
define num_days = '';
--
--   List last 31 days
-- define num_days = 31;
--
--   List no (i.e. 0) snapshots
-- define num_days = 0;


-- -------------------------------------------------------------------------

--
-- SQL related report settings

-- Number of Rows of SQL to display in each SQL section of the report
define top_n_sql = 65;

-- Number of rows of SQL Text to print in the SQL sections of the report
-- for each hash_value
define num_rows_per_hash = 4;

-- Filter which restricts the rows of SQL shown in the SQL sections of the 
-- report to be the top N pct
define top_pct_sql = 1.0;


-- -------------------------------------------------------------------------

--
-- Segment related report settings

-- The number of top segments to display in each of the High-Load Segment 
-- sections of the report
define top_n_segstat = 5;


-- -------------------------------------------------------------------------

--
--  Rollback Segment and Auto-Undo segment stats

--  
-- Whether or not to display rollback segment stats.  Value of N is only
-- honoured only if Auto-Undo is enabled.  Valid values are N or Y

-- Display Rollstat stats
--define display_rollstat = 'Y';
-- Do not display Rollstat stats
define display_rollstat = 'N';

-- Whether or not to Auto-undo segment stats.  Valid values are N or Y
-- Display unodstat stats
define display_undostat = 'Y';
-- Do not display unodstat stats
--define display_undostat = 'N';
-- Number of undostat entries to show
define top_n_undostat = 35;


-- -------------------------------------------------------------------------

--
-- File IO statistics related report settings

--
-- BEWARE - only comment this section out if you KNOW you do not have
-- IO problems!

-- Display file-level statistics in the report
define display_file_io = 'Y';
-- Do not display file-level statistics in the report
--define display_file_io = 'N';


-- -------------------------------------------------------------------------

--
--  File and Event Histogram Stats

--
-- File Histogram statistics related report settings


-- Do not print File Histogram stats in the report
--define file_histogram = N;
-- Display File Histogram stats in the report
define file_histogram = 'Y';


--
-- Event Histogram statistics related report settings
-- (whether or not to display histogram statistics in the report)

--  Do not print Event Histogram stats
--define event_histogram = N;
--  Print Event histogram stats
define event_histogram = 'Y';


-- -------------------------------------------------------------------------

--
-- Streams related report settings
--
define streams_top_n = 25


-- -------------------------------------------------------------------------

--
-- RAC Global Cache Transfer Statistics related report setting
-- (should the cache transfer statistics be detailed per instance)

-- Print aggregated cache transfer statistics
--define cache_xfer_per_instance = 'N';
--  Print per instance cache transfer statistics
define cache_xfer_per_instance = 'Y';


-- -------------------------------------------------------------------------

--
-- SGA Stat report settings
define sgastat_top_n = 35


-- -------------------------------------------------------------------------

--
-- Wait Events - average wait time granularity for System Event section
-- of Instance report
-- NOTE:  when increasing the width of avwt_fmt, you might also want to
-- increase report linesize width. 
-- Changing the defaults for the two values below is only recommended for
-- benchmark situations which require finer granularity timings.
define avwt_fmt     = 99990
define linesize_fmt = 80
--define avwt_fmt     = 99990.99
--define linesize_fmt = 83



-- -------------------------------------------------------------------------

Rem     -------------                End  of                -----------
Rem     ------------- Customer Configurable Report Settings -----------
-- -------------------------------------------------------------------------

