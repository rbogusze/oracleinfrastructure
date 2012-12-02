PROMPT bde_rebuild.sql - Validates and rebuilds indexes occupying more space than needed [ID 182699.1]
SET term off ver off trims on serveroutput on size 1000000 feed off;

DROP   TABLE bde_index_stats;
CREATE TABLE bde_index_stats
       AS SELECT * FROM index_stats WHERE 1=2;
ALTER  TABLE bde_index_stats
       ADD (index_owner VARCHAR2(30),index_name VARCHAR2(30),
            analyzed DATE,row_num NUMBER);

SET term on pages 0 lin 255;
ACCEPT schema     PROMPT 'Enter Owner of Table(s) (Schema) <opt>: ';
ACCEPT table_name PROMPT 'Enter Table Name................ <opt>: ';
ACCEPT index_name PROMPT 'Enter Index Name or Index Suffix <opt>: ';
ACCEPT threshold  PROMPT 'Enter threshold between 20 and 80<opt>: ';
PROMPT
PROMPT Generating bde_validate_structure&&schema&&table_name&&index_name..sql;
PROMPT
SET term off;

VARIABLE v_count NUMBER;

SPOOL bde_validate_structure&&schema&&table_name&&index_name..sql;
DECLARE
   v_sql        VARCHAR2(1000);
   v_dbversion  v$instance.version%TYPE;
   CURSOR c1 IS
      SELECT owner,
             index_name
        FROM all_indexes
       WHERE table_owner LIKE RTRIM(UPPER('&&schema'))||'%'
         AND table_name  LIKE RTRIM(UPPER('&&table_name'))||'%'
         AND index_name  LIKE '%'||RTRIM(UPPER('&&index_name'))||'%'
         AND table_owner <> 'SYS'
         AND owner       <> 'SYS'
         AND table_owner <> 'SYSTEM'
         AND owner       <> 'SYSTEM'
       ORDER BY
             owner,
             index_name;
BEGIN
   SELECT version INTO v_dbversion FROM v$instance;
   v_sql:='/*$Header: bde_validate_structure'||
          '&&schema&&table_name&&index_name..sql '||
          '(8.0-9.2) '||TO_CHAR(sysdate,'YYYY/MM/DD')||
          '   gen by bde_rebuild.sql   csierra bde $*/';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SET echo on feed on;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SPOOL bde_validate_structure&&schema&&table_name&&index_name..txt;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   :v_count:=0;
   FOR c1_rec IN c1 LOOP
      :v_count:=:v_count+1;
      v_sql:='ANALYZE INDEX '||c1_rec.owner||'.'||c1_rec.index_name||
             ' VALIDATE STRUCTURE;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
      v_sql:='INSERT INTO bde_index_stats '||
             'SELECT ixs.*, '''||c1_rec.owner||''', '''||c1_rec.index_name||''', '||
             'sysdate, '||:v_count||
              ' FROM index_stats ixs;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
   END LOOP;
   v_sql:='COMMIT;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SPOOL off;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SET echo off feed off;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
END;
/
SPOOL off;

SET term on;
PROMPT
EXEC DBMS_OUTPUT.PUT_LINE('Number of indexes selected: '||TO_CHAR(:v_count));
PROMPT
PROMPT Ready to execute generated script to validate selected indexes:
PROMPT bde_validate_structure&&schema&&table_name&&index_name..sql;
PROMPT
PROMPT *** WARNING ***
PROMPT This script blocks DML commands on indexes beign analyzed, including
PROMPT SELECT statements.
PROMPT Execute in Production during a low online user activity period.
PROMPT Blocking time lasts between a few secs to a few minutes, depending on
PROMPT index size.
PROMPT
PAUSE Click <Enter> to continue, or <Ctrl-c> to cancel
PROMPT
PROMPT Executing bde_validate_structure&&schema&&table_name&&index_name..sql;
PROMPT
START bde_validate_structure&&schema&&table_name&&index_name..sql;
PROMPT
PROMPT
PROMPT Generating bde_rebuild_indexes&&schema&&table_name&&index_name..sql;
PROMPT
SET term off;

SPOOL bde_rebuild_indexes&&schema&&table_name&&index_name..sql;
DECLARE
   v_sql        VARCHAR2(1000);
   v_dbversion  v$instance.version%TYPE;
   CURSOR c1 IS
      SELECT index_owner,
             index_name
        FROM bde_index_stats
       WHERE SIGN(del_lf_rows_len/DECODE(lf_rows_len,0,1,lf_rows_len)-(TO_NUMBER(NVL('&&threshold','50'))/100))=1
       ORDER BY
             index_owner,
             index_name;
BEGIN
   SELECT version INTO v_dbversion FROM v$instance;
   v_sql:='/*$Header: bde_rebuild_indexes'||
          '&&schema&&table_name&&index_name..sql '||
          '(8.0-9.2) '||TO_CHAR(sysdate,'YYYY/MM/DD')||
          '   gen by bde_rebuild.sql   csierra bde $*/';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SET echo on feed on;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SPOOL bde_rebuild_indexes&&schema&&table_name&&index_name..txt;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   :v_count:=0;
   FOR c1_rec IN c1 LOOP
      :v_count:=:v_count+1;
      v_sql:='ALTER INDEX '||c1_rec.index_owner||'.'||c1_rec.index_name||
             ' REBUILD ';
      IF v_dbversion > '8.1' THEN
         v_sql:=v_sql||'ONLINE ';
      END IF;
      v_sql:=v_sql||'NOLOGGING;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
      v_sql:='ALTER INDEX '||c1_rec.index_owner||'.'||c1_rec.index_name||
             ' LOGGING;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
      v_sql:='ANALYZE INDEX '||c1_rec.index_owner||'.'||c1_rec.index_name||
             ' COMPUTE STATISTICS;';
      DBMS_OUTPUT.PUT_LINE(v_sql);
   END LOOP;
   v_sql:='SPOOL off;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
   v_sql:='SET echo off;';
   DBMS_OUTPUT.PUT_LINE(v_sql);
END;
/
SPOOL off;

SET term on;
PROMPT
PROMPT Generating bde_rebuild_report&&schema&&table_name&&index_name..txt
PROMPT
SET term off numf 999,999,999,999,999 pages 10000 lin 500;

CLEAR COLUMNS BREAKS COMPUTES;
COLUMN NAME                   FORMAT A60 HEADING -
    'Segment Name|[OWNER.INDEX_NAME.PARTITION_NAME]';
COLUMN NAME2                  FORMAT A60 HEADING -
    'Segment Name|[OWNER.INDEX_NAME]';
COLUMN HEIGHT                 HEADING -
    'Index Depth|[HEIGHT]';
COLUMN BLOCKS                 HEADING -
    'Segment Size|[BLOCKS]';
COLUMN NUM_ROWS               HEADING -
    'Num of Rows|[LF_ROWS]';
COLUMN LF_ROWS                HEADING -
    'Num of Leaf Rows|[LF_ROWS]';
COLUMN LF_BLKS                HEADING -
    'Num of Leaf Blocks|[LF_BLKS]';
COLUMN LF_ROWS_LEN            HEADING -
    'Sum of lengths|of all Leaf Rows|[LF_ROWS_LEN]';
COLUMN LF_BLK_LEN             HEADING -
    'Average length of|a Leaf Block|[LF_BLK_LEN]';
COLUMN BR_ROWS                HEADING -
    'Num of|Branch Rows|[BR_ROWS]';
COLUMN BR_BLKS                HEADING -
    'Num of|Branch Blocks|[BR_BLKS]';
COLUMN BR_ROWS_LEN            HEADING -
    'Sum of lengths|of all|Branch Rows|[BR_ROWS_LEN]';
COLUMN BR_BLK_LEN             HEADING -
    'Average length of|a Branch Block|[BR_BLK_LEN]';
COLUMN DEL_LF_ROWS            HEADING -
    'Num of Deleted|Leaf Rows|[DEL_LF_ROWS]';
COLUMN DEL_LF_ROWS_LEN        HEADING -
    'Sum of lengths|of all|Deleted Leaf Rows|[DEL_LF_ROWS_LEN]';
COLUMN DISTINCT_KEYS          HEADING -
    'Num of|[DISTINCT_KEYS]';
COLUMN MOST_REPEATED_KEY      HEADING -
    'Times Most|Repeated Key|is Repeated|[MOST_REPEATED_KEY]';
COLUMN BTREE_SPACE            HEADING -
    'Allocated and|Usable Space|[BTREE_SPACE]';
COLUMN USED_SPACE             HEADING -
    '[USED_SPACE]';
COLUMN PCT_USED               HEADING -
    'Percent of|Allocated Space|being used|[PCT_USED]';
COLUMN ROWS_PER_KEY           HEADING -
    'Average Num of Rows|per Distinct Key|[ROWS_PER_KEY]';
COLUMN BLKS_GETS_PER_ACCESS   HEADING -
  'Logical Reads|Expected to access|one Distinct Key|[BLKS_GETS_| PER_ACCESS]';
COLUMN WASTED_SPACE           HEADING -
    'Percent of|Wasted Space|caused by|Deleted Leaf Rows';
COLUMN ANALYZED               FORMAT A19 HEADING -
    'Analyzed|Validate|Structure';
COLUMN ROW_NUM                HEADING -
    'Row Number|during Analyze';

SPOOL bde_rebuild_report&&schema&&table_name&&index_name..txt;
SET term on;

PROMPT
PROMPT Indexes selected for Rebuild
PROMPT ============================
PROMPT

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       ROUND(del_lf_rows_len*100/DECODE(lf_rows_len,0,1,lf_rows_len))
           wasted_space
  FROM bde_index_stats
 WHERE SIGN(del_lf_rows_len/DECODE(lf_rows_len,0,1,lf_rows_len)-(TO_NUMBER(NVL('&&threshold','50'))/100))=1
ORDER BY 1;

SET term off;
PROMPT
PROMPT
PROMPT INDEX_STATS
PROMPT ===========
PROMPT

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       height,
       blocks,
       lf_blks,
       br_blks,
       btree_space,
       used_space,
       pct_used
  FROM bde_index_stats
 ORDER BY 1;

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       lf_rows num_rows,
       distinct_keys,
       rows_per_key,
       blks_gets_per_access,
       most_repeated_key
  FROM bde_index_stats
ORDER BY 1;

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       lf_blks,
       lf_blk_len,
       lf_rows,
       lf_rows_len,
       del_lf_rows,
       del_lf_rows_len,
       ROUND(del_lf_rows_len*100/DECODE(lf_rows_len,0,1,lf_rows_len))
           wasted_space
  FROM bde_index_stats
ORDER BY 1;

SELECT RPAD(SUBSTR(index_owner||'.'||index_name||
       DECODE(partition_name,NULL,NULL,'.'||
              partition_name),1,60),60,'.') name,
       br_blks,
       br_blk_len,
       br_rows,
       br_rows_len,
       TO_CHAR(analyzed,'DD-MON-YY HH24:MI:SS') analyzed,
       row_num
  FROM bde_index_stats
ORDER BY 1;

SPOOL OFF;

SET term on;
PROMPT
PROMPT Report and Log file have been generated
PROMPT
EXEC DBMS_OUTPUT.PUT_LINE('Identified indexes: '||TO_CHAR(:v_count));
PROMPT
PROMPT Ready to execute generated script to rebuild indexes occupying more space than needed:
PROMPT bde_rebuild_indexes&&schema&&table_name&&index_name..sql;
PROMPT
-- START bde_rebuild_indexes&&schema&&table_name&&index_name..sql;
CLEAR COLUMNS BREAKS COMPUTES;
SET pages 24 lin 80 ver on trims off feed on numf 9999999999 serveroutput off;
