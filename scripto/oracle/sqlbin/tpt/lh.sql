--------------------------------------------------------------------------------
--
-- File name:   lh.sql ( Latch Holder )
-- Purpose:     Show latch holding SIDs and latch details from V$LATCHHOLDER
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @lh <sid>
-- 	        	@lh %
--
--------------------------------------------------------------------------------
SELECT
	*
FROM
	V$LATCHHOLDER
WHERE
	sid LIKE '&1'
/



