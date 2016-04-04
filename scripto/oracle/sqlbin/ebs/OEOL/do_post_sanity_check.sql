-- =====================================================================================================
-- Created gverma - 23nd feb 2007
--
-- This script checks if all the required tables have been made and populated which are required for the
-- reports to run well.
-- =====================================================================================================

prompt Checking table oeoh_oeol_wias
desc oeoh_oeol_wias
select count(1) from oeoh_oeol_wias;
prompt Checking table oeoh_oeol_wias_h
desc oeoh_oeol_wias_h
select count(1) from oeoh_oeol_wias_h;
prompt Checking table merged_oeoh_oeol_wf
desc merged_oeoh_oeol_wf
select count(1) from merged_oeoh_oeol_wf;
prompt Checking table unique_orders
desc unique_orders
select count(1) from unique_orders;
exit;
