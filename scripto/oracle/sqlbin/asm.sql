COL % FORMAT 99.0
SELECT name, free_mb, total_mb, free_mb/total_mb*100 "%" FROM v$asm_diskgroup;
