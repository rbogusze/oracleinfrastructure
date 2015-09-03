--------------------------------------------------------------------------------
--
-- File name:   usql (show outher User's SQL)
-- Purpose:     Show another session's SQL directly from library cache
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @usql <sid>
-- 	        @usql 150
--	        
-- Other:       This script calls sql.sql (for displaying SQL text) and xmsh.sql
--              (for displaying execution plan)           
--              
--
--------------------------------------------------------------------------------


def _usql_sid="&1"

@@sql  "select /*+ NO_MERGE */ sql_hash_value from v$session where sid in (&_usql_sid)"
--@@xmsh "select /*+ NO_MERGE */ sql_hash_value from v$session where sid in (&_usql_sid)" %

undef _usql_sid
