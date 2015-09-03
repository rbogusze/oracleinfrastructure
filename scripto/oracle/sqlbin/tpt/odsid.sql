SET TERMOUT OFF
COL spid NEW_VALUE odsid_spid
SELECT spid FROM v$process WHERE addr = (SELECT /*+ NO_UNNEST */ paddr FROM v$session WHERE sid = &1);
COL spid CLEAR
SET TERMOUT ON

ORADEBUG SETOSPID &odsid_spid
