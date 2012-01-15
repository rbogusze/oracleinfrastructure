select SQL_TEXT from V$SQLTEXT where HASH_VALUE='&1' order by piece;
