SPOOL bde_chk_cbo.log;
SET ECHO ON TERM OFF;
REM
REM $Header: 174605.1 bde_chk_cbo.sql 12.1.04 2013/11/11 csierra $
REM
REM Copyright (c) 2000-2012, Oracle Corporation. All rights reserved.
REM
REM AUTHOR
REM   carlos.sierra@oracle.com
REM
REM NAME
REM   bde_chk_cbo.sql
REM
REM DESCRIPTION
REM   Lists EBS initialization parameters side by side to
REM   those from official notes 216205.1 and 396009.1
REM
REM PRE-REQUISITES
REM   1. Only used by EBS (Oracle Applications - APPS).
REM   2. Execute connecting as APPS.
REM
REM PARAMETERS
REM   None.
REM
REM EXAMPLE
REM   #sqlplus apps
REM   SQL> START bde_chk_cbo.sql;
REM
REM UPDATES
REM   dchbane  2013/11/11  Added parameters for 12cR1
REM

SET FEED OFF VER OFF HEA OFF LIN 2000 PAGES 0 TRIMS ON;

VAR v_cpu_count     VARCHAR2(10);
VAR v_database      VARCHAR2(32);
VAR v_host          VARCHAR2(64);
VAR v_instance      VARCHAR2(32);
VAR v_platform      VARCHAR2(80);
VAR v_rdbms_release VARCHAR2(17);
VAR v_rdbms_version VARCHAR2(17);
VAR v_apps_release  VARCHAR2(50);
VAR v_sysdate       VARCHAR2(15);
VAR v_user          VARCHAR2(30);

COL p_cpu_count     NEW_V p_cpu_count     FOR A10;
COL p_database      NEW_V p_database      FOR A32;
COL p_host          NEW_V p_host          FOR A64;
COL p_instance      NEW_V p_instance      FOR A32;
COL p_platform      NEW_V p_platform      FOR A80;
COL p_rdbms_release NEW_V p_rdbms_release FOR A17;
COL p_rdbms_version NEW_V p_rdbms_version FOR A10;
COL p_apps_release  NEW_V p_apps_release  FOR A50;
COL p_sysdate       NEW_V p_sysdate       FOR A15;
COL p_user          NEW_V p_user          FOR A30;

/******************************************************************************/

EXEC :v_cpu_count     := 'Unknown';
EXEC :v_database      := 'Unknown';
EXEC :v_host          := 'Unknown';
EXEC :v_instance      := 'Unknown';
EXEC :v_platform      := 'Unknown';
EXEC :v_rdbms_release := 'Unknown';
EXEC :v_rdbms_version := 'Unknown';
EXEC :v_apps_release  := 'Unknown';
EXEC :v_sysdate       := TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI');
EXEC :v_user          := USER;

BEGIN
    SELECT i.host_name,
           i.version,
           SUBSTR(UPPER(i.instance_name)||'('||TO_CHAR(i.instance_number)||')', 1, 40)
      INTO :v_host, :v_rdbms_release, :v_instance
      FROM v$instance i;
END;
/

-- If you need to execute in preparation for an upgrade, just uncomment one of the 5 commands below:
--EXEC :v_rdbms_release := '8.1.7.X';
--EXEC :v_rdbms_release := '9.2.0.X';
--EXEC :v_rdbms_release := '10.1.X';
--EXEC :v_rdbms_release := '10.2.X';
--EXEC :v_rdbms_release := '11.1.X';
--EXEC :v_rdbms_release := '11.2.X';
--EXEC :v_rdbms_release := '12.1.X';

BEGIN
    :v_rdbms_version := :v_rdbms_release;
    IF :v_rdbms_release LIKE '12.1.%' THEN :v_rdbms_version := '12.1.X'; END IF;
    IF :v_rdbms_release LIKE '11.2.%' THEN :v_rdbms_version := '11.2.X'; END IF;
    IF :v_rdbms_release LIKE '11.1.%' THEN :v_rdbms_version := '11.1.X'; END IF;
    IF :v_rdbms_release LIKE '10.2.%' THEN :v_rdbms_version := '10.2.X'; END IF;
    IF :v_rdbms_release LIKE '10.1.%' THEN :v_rdbms_version := '10.1.X'; END IF;
    IF :v_rdbms_release LIKE '9.2.0.%' THEN :v_rdbms_version := '9.2.0.X'; END IF;
    IF :v_rdbms_release LIKE '8.1.7.%' THEN :v_rdbms_version := '8.1.7.X'; END IF;
END;
/

BEGIN
    SELECT db.name||'('||TO_CHAR(db.dbid)||')'
      INTO :v_database
      FROM v$database db;
END;
/

BEGIN
    SELECT SUBSTR(value, 1, 10)
      INTO :v_cpu_count
      FROM v$parameter
     WHERE name = 'cpu_count';
END;
/

BEGIN
    SELECT SUBSTR(REPLACE(REPLACE(pcv1.product, 'TNS for '), ':' )||pcv2.status, 1, 80)
      INTO :v_platform
      FROM product_component_version pcv1,
           product_component_version pcv2
     WHERE UPPER(pcv1.product) LIKE '%TNS%'
       AND UPPER(pcv2.product) LIKE '%ORACLE%'
       AND ROWNUM = 1;
END;
/

BEGIN
    SELECT release_name
      INTO :v_apps_release
      FROM applsys.fnd_product_groups;
END;
/

SELECT :v_cpu_count     p_cpu_count,
       :v_database      p_database,
       :v_host          p_host,
       :v_instance      p_instance,
       :v_platform      p_platform,
       :v_rdbms_release p_rdbms_release,
       :v_rdbms_version p_rdbms_version,
       :v_sysdate       p_sysdate,
       :v_apps_release  p_apps_release,
       :v_user          p_user
  FROM DUAL;

DROP TABLE chk$cbo$parameter_apps;
CREATE TABLE chk$cbo$parameter_apps (
  release                    VARCHAR2(64) NOT NULL,
  version                    VARCHAR2(32) NOT NULL,
  id                         INTEGER NOT NULL,
  name                       VARCHAR2(128) NOT NULL,
  set_flag                   CHAR(1) NOT NULL,
  mp_flag                    CHAR(1) NOT NULL,
  sz_flag                    CHAR(1) NOT NULL,
  cbo_flag                   CHAR(1) NOT NULL,
  value                      VARCHAR2(512)
);

CREATE OR REPLACE PROCEDURE chk$ebs$parameters (
  p_rdbms_version IN VARCHAR2,
  p_apps_release  IN VARCHAR2 )
IS
  my_sequence INTEGER := 0;

  PROCEDURE ins (
    p_version  IN VARCHAR2,
    p_name     IN VARCHAR2,
    p_set_flag IN VARCHAR2,
    p_mp_flag  IN VARCHAR2,
    p_sz_flag  IN VARCHAR2,
    p_cbo_flag IN VARCHAR2,
    p_value    IN VARCHAR2 )
  IS
    my_count INTEGER;
  BEGIN
    IF p_version <> 'COMMON' AND p_version <> p_rdbms_version THEN
      RETURN;
    END IF;

    SELECT COUNT(*)
      INTO my_count
      FROM chk$cbo$parameter_apps
     WHERE name = p_name;

    my_sequence := my_sequence + 1;

    IF my_count = 0 THEN
      INSERT INTO chk$cbo$parameter_apps VALUES (
        p_apps_release,
        p_version,
        my_sequence,
        p_name,
        p_set_flag,
        p_mp_flag,
        p_sz_flag,
        p_cbo_flag,
        p_value );
    ELSE
      UPDATE chk$cbo$parameter_apps SET
        release  = p_apps_release,
        version  = p_version,
        id       = my_sequence,
        set_flag = p_set_flag,
        mp_flag  = p_mp_flag,
        sz_flag  = p_sz_flag,
        cbo_flag = p_cbo_flag,
        value    = p_value
      WHERE name = p_name;
    END IF;
  END ins;

BEGIN
  IF NVL(p_rdbms_version, 'Unknown') = 'Unknown' OR NVL(p_apps_release, 'Unknown') = 'Unknown' THEN
    RETURN;
  END IF;

  IF p_apps_release LIKE '11%' THEN
    /*  version    name                               set  mp   sz   cbo  value                               */
    /*  ========== =============================      ===  ===  ===  ===  =================================== */
    ins('COMMON',  'db_name',                         'Y', 'N', 'N', 'N', 'prod11i');
    ins('COMMON',  'control_files',                   'Y', 'N', 'N', 'N', 'three copies of control file');
    ins('COMMON',  'db_block_size',                   'Y', 'Y', 'N', 'N', '8192');
    ins('COMMON',  '_system_trig_enabled',            'Y', 'Y', 'N', 'N', 'TRUE');
    IF p_apps_release IN ('11.5.1', '11.5.2', '11.5.3', '11.5.4', '11.5.5', '11.5.6', '11.5.7', '11.5.8', '11.5.9') THEN
      ins('COMMON',  'o7_dictionary_accessibility',   'Y', 'Y', 'N', 'N', 'TRUE');
    ELSE
      ins('COMMON',  'o7_dictionary_accessibility',   'Y', 'Y', 'N', 'N', 'FALSE');
    END IF;
    ins('COMMON',  'nls_language',                    'Y', 'N', 'N', 'N', 'AMERICAN');
    ins('COMMON',  'nls_territory',                   'Y', 'N', 'N', 'N', 'AMERICA');
    ins('COMMON',  'nls_date_format',                 'Y', 'Y', 'N', 'N', 'DD-MON-RR');
    ins('COMMON',  'nls_numeric_characters',          'Y', 'N', 'N', 'N', '".,"');
    ins('COMMON',  'nls_sort',                        'Y', 'Y', 'N', 'N', 'BINARY');
    ins('COMMON',  'nls_comp',                        'Y', 'Y', 'N', 'N', 'BINARY');
    ins('COMMON',  'audit_trail',                     'Y', 'N', 'N', 'N', 'TRUE (optional)');
    ins('COMMON',  'max_enabled_roles',               'Y', 'Y', 'N', 'N', '100');
    ins('COMMON',  'user_dump_dest',                  'Y', 'N', 'N', 'N', '?/prod11i/udump');
    ins('COMMON',  'background_dump_dest',            'Y', 'N', 'N', 'N', '?/prod11i/bdump');
    ins('COMMON',  'core_dump_dest',                  'Y', 'N', 'N', 'N', '?/prod11i/cdump');
    ins('COMMON',  'max_dump_file_size',              'Y', 'N', 'N', 'N', '20480');
    ins('COMMON',  'timed_statistics',                'Y', 'N', 'N', 'N', 'TRUE');
    ins('COMMON',  '_trace_files_public',             'Y', 'N', 'N', 'N', 'TRUE');
    ins('COMMON',  'sql_trace',                       'Y', 'N', 'N', 'N', 'FALSE');
    ins('COMMON',  'processes',                       'Y', 'N', 'Y', 'N', '200-2500');
    ins('COMMON',  'sessions',                        'Y', 'N', 'Y', 'N', '400-5000');
    ins('COMMON',  'db_files',                        'Y', 'N', 'N', 'N', '512');
    ins('COMMON',  'dml_locks',                       'Y', 'N', 'N', 'N', '10000');
    ins('COMMON',  'enqueue_resources',               'Y', 'N', 'N', 'N', '32000');
    ins('COMMON',  'cursor_sharing',                  'Y', 'Y', 'N', 'Y', 'EXACT');
    ins('COMMON',  'open_cursors',                    'Y', 'N', 'N', 'N', '600');
    ins('COMMON',  'session_cached_cursors',          'Y', 'N', 'N', 'N', '200');
    ins('COMMON',  'db_block_buffers',                'Y', 'N', 'Y', 'N', '20000-400000');
    ins('COMMON',  'db_block_checking',               'Y', 'N', 'N', 'N', 'FALSE');
    ins('COMMON',  'db_block_checksum',               'Y', 'N', 'N', 'N', 'TRUE');
    ins('COMMON',  'log_checkpoint_timeout',          'Y', 'N', 'N', 'N', '1200');
    ins('COMMON',  'log_checkpoint_interval',         'Y', 'N', 'N', 'N', '100000');
    ins('COMMON',  'log_buffer',                      'Y', 'N', 'N', 'N', '10485760');
    ins('COMMON',  'log_checkpoints_to_alert',        'Y', 'N', 'N', 'N', 'TRUE');
    ins('COMMON',  'shared_pool_size',                'Y', 'N', 'Y', 'N', '400-3000M');
    ins('COMMON',  'shared_pool_reserved_size',       'Y', 'N', 'Y', 'N', '40-300M');
    ins('COMMON',  '_shared_pool_reserved_min_alloc', 'Y', 'N', 'N', 'N', '4100');
    ins('COMMON',  'cursor_space_for_time',           'Y', 'N', 'N', 'N', 'FALSE (default)');
    ins('COMMON',  'java_pool_size',                  'Y', 'N', 'N', 'N', '50M');
    ins('COMMON',  'utl_file_dir',                    'Y', 'N', 'N', 'N', '?/prod11i/utl_file_dir');
    ins('COMMON',  'aq_tm_processes',                 'Y', 'N', 'N', 'N', '1');
    ins('COMMON',  'job_queue_processes',             'Y', 'N', 'N', 'N', '2');
    ins('COMMON',  'log_archive_start',               'Y', 'N', 'N', 'N', 'TRUE (optional)');
    ins('COMMON',  'parallel_max_servers',            'Y', 'N', 'N', 'N', '8 (up to 2*CPUs)');
    ins('COMMON',  'parallel_min_servers',            'Y', 'N', 'N', 'N', '0');
    ins('COMMON',  'db_file_multiblock_read_count',   'Y', 'Y', 'N', 'Y', '8');
    ins('COMMON',  'optimizer_max_permutations',      'Y', 'Y', 'N', 'Y', '2000');
    ins('COMMON',  'query_rewrite_enabled',           'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('COMMON',  '_sort_elimination_cost_ratio',    'Y', 'Y', 'N', 'Y', '5');
    ins('COMMON',  '_like_with_bind_as_equality',     'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('COMMON',  '_fast_full_scan_enabled',         'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('COMMON',  '_sqlexec_progression_cost',       'Y', 'Y', 'N', 'Y', '2147483647');
    ins('COMMON',  'max_commit_propagation_delay',    'Y', 'Y', 'N', 'N', '0 (if using RAC)');
    ins('COMMON',  'cluster_database',                'Y', 'Y', 'N', 'N', 'TRUE (if using RAC)');
    ins('COMMON',  'instance_groups',                 'Y', 'N', 'N', 'N', 'appsN (N is inst_id if using RAC)');
    ins('COMMON',  'parallel_instance_group',         'Y', 'N', 'N', 'N', 'appsN (N is inst_id if using RAC)');
    /* Release-specific database initialization parameters for 8iR3 (8.1.7.X) */
    ins('8.1.7.X', 'compatible',                      'Y', 'Y', 'N', 'N', '8.1.7');
    ins('8.1.7.X', 'rollback_segments',               'Y', 'N', 'N', 'N', '(rbs1,rbs2,rbs3,rbs4,rbs5,rbs6)');
    ins('8.1.7.X', 'sort_area_size',                  'Y', 'N', 'N', 'Y', '1048576');
    ins('8.1.7.X', 'hash_area_size',                  'Y', 'N', 'N', 'Y', '2097152');
    ins('8.1.7.X', 'job_queue_interval',              'Y', 'N', 'N', 'N', '90');
    ins('8.1.7.X', 'optimizer_features_enable',       'Y', 'Y', 'N', 'Y', '8.1.7');
    ins('8.1.7.X', '_optimizer_undo_changes',         'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('8.1.7.X', '_optimizer_mode_force',           'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('8.1.7.X', '_complex_view_merging',           'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('8.1.7.X', '_push_join_predicate',            'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('8.1.7.X', '_use_column_stats_for_function',  'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('8.1.7.X', '_or_expand_nvl_predicate',        'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('8.1.7.X', '_push_join_union_view',           'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('8.1.7.X', '_table_scan_cost_plus_one',       'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('8.1.7.X', '_ordered_nested_loop',            'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('8.1.7.X', '_new_initial_join_orders',        'Y', 'Y', 'N', 'Y', 'TRUE');
    /* Removal list for 8iR3 (8.1.7.X) */
    ins('8.1.7.X', '_b_tree_bitmap_plans',            'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', 'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', 'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', 'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('8.1.7.X', 'event="10929 trace name context forever"',          'N', 'N', 'N', 'N', NULL);
    ins('8.1.7.X', 'event="10932 trace name context level 2"',          'N', 'N', 'N', 'N', NULL);
    ins('8.1.7.X', 'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', 'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', 'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('8.1.7.X', 'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    /* Release-specific database initialization parameters for 9iR2 (9.2.0.X) */
    ins('9.2.0.X', 'compatible',                      'Y', 'Y', 'N', 'N', '9.2.0');
    ins('9.2.0.X', 'db_cache_size',                   'Y', 'N', 'Y', 'N', '156M-3G');
    ins('9.2.0.X', 'nls_length_semantics',            'Y', 'Y', 'N', 'N', 'BYTE');
    ins('9.2.0.X', 'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('9.2.0.X', 'undo_retention',                  'Y', 'N', 'Y', 'N', '1800-14400');
    ins('9.2.0.X', 'undo_suppress_errors',            'Y', 'Y', 'N', 'N', 'FALSE');
    ins('9.2.0.X', 'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('9.2.0.X', 'pga_aggregate_target',            'Y', 'N', 'Y', 'Y', '1-20G');
    ins('9.2.0.X', 'workarea_size_policy',            'Y', 'Y', 'N', 'Y', 'AUTO');
    ins('9.2.0.X', 'olap_page_pool_size',             'Y', 'N', 'N', 'N', '4194304');
    IF p_apps_release IN ('11.5.5', '11.5.6', '11.5.7') THEN
      /* These events should only be used if you are using Oracle Applications release 11.5.7 or prior*/
      ins('9.2.0.X', 'event="10932 trace name context level 32768"', 'Y', 'N', 'N', 'N', NULL);
      ins('9.2.0.X', 'event="10933 trace name context level 512"',   'Y', 'N', 'N', 'N', NULL);
      ins('9.2.0.X', 'event="10943 trace name context level 16384"', 'Y', 'N', 'N', 'N', NULL);
    END IF;
    ins('9.2.0.X', 'optimizer_features_enable',       'Y', 'Y', 'N', 'Y', '9.2.0');
    ins('9.2.0.X', '_index_join_enabled',             'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('9.2.0.X', '_b_tree_bitmap_plans',            'Y', 'Y', 'N', 'Y', 'FALSE');
    /* Removal list for 9iR2 (9.2.0.X) */
    ins('9.2.0.X', 'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', 'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', 'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('9.2.0.X', 'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('9.2.0.X', 'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('9.2.0.X', 'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('9.2.0.X', 'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', 'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', 'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', 'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', 'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('9.2.0.X', 'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    IF p_apps_release NOT IN ('11.5.1', '11.5.2', '11.5.3', '11.5.4', '11.5.5', '11.5.6', '11.5.7') THEN
    /* Remove the following events only if you are using Oracle Applications release 11.5.8 or later. */
      ins('9.2.0.X', 'event="10932 trace name context level 32768"', 'N', 'N', 'N', 'N', NULL);
      ins('9.2.0.X', 'event="10933 trace name context level 512"',   'N', 'N', 'N', 'N', NULL);
      ins('9.2.0.X', 'event="10943 trace name context level 16384"', 'N', 'N', 'N', 'N', NULL);
    END IF;
    /* Release-specific database initialization parameters for 10gR1 (10.1.X) */
    ins('10.1.X',  'compatible',                      'Y', 'Y', 'N', 'N', '10.1.0');
    ins('10.1.X',  'sga_target',                      'Y', 'N', 'Y', 'N', '1-14G');
    ins('10.1.X',  'shared_pool_size',                'Y', 'N', 'Y', 'N', '400-3000M');
    ins('10.1.X',  'shared_pool_reserved_size',       'Y', 'N', 'Y', 'N', '40-300M');
    ins('10.1.X',  'nls_length_semantics',            'Y', 'Y', 'N', 'N', 'BYTE');
    ins('10.1.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('10.1.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('10.1.X',  'pga_aggregate_target',            'Y', 'N', 'Y', 'Y', '1-20G');
    ins('10.1.X',  'workarea_size_policy',            'Y', 'Y', 'N', 'Y', 'AUTO');
    ins('10.1.X',  'olap_page_pool_size',             'Y', 'N', 'N', 'N', '4194304');
    ins('10.1.X',  'open_cursors',                    'Y', 'N', 'N', 'N', '600');
    ins('10.1.X',  'session_cached_cursors',          'Y', 'N', 'N', 'N', '500');
    ins('10.1.X',  'plsql_optimize_level',            'Y', 'Y', 'N', 'N', '2');
    ins('10.1.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'INTERPRETED');
    ins('10.1.X',  'plsql_native_library_dir',        'Y', 'N', 'N', 'N', '?/prod11i/plsql_nativelib (if using NATIVE PL/SQL)');
    ins('10.1.X',  'plsql_native_library_subdir_count', 'Y', 'N', 'N', 'N', '149 (if using NATIVE PL/SQL)');
    ins('10.1.X',  '_b_tree_bitmap_plans',            'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('10.1.X',  'aq_tm_processes',                 'Y', 'N', 'N', 'N', '1');
    /* Removal list for 10gR1 (10.1.X) */
    ins('10.1.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('10.1.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('10.1.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    /* Release-specific database initialization parameters for 10gR2 (10.2.X) */
    ins('10.2.X',  'compatible',                      'Y', 'Y', 'N', 'N', '10.2.0');
    ins('10.2.X',  'sga_target',                      'Y', 'N', 'Y', 'N', '1-14G');
    ins('10.2.X',  'shared_pool_size',                'Y', 'N', 'Y', 'N', '400-3000M');
    ins('10.2.X',  'shared_pool_reserved_size',       'Y', 'N', 'Y', 'N', '40-300M');
    ins('10.2.X',  'nls_length_semantics',            'Y', 'Y', 'N', 'N', 'BYTE');
    ins('10.2.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('10.2.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('10.2.X',  'pga_aggregate_target',            'Y', 'N', 'Y', 'Y', '1-20G');
    ins('10.2.X',  'workarea_size_policy',            'Y', 'Y', 'N', 'Y', 'AUTO');
    ins('10.2.X',  'olap_page_pool_size',             'Y', 'N', 'N', 'N', '4194304');
    ins('10.2.X',  'open_cursors',                    'Y', 'N', 'N', 'N', '600');
    ins('10.2.X',  'session_cached_cursors',          'Y', 'N', 'N', 'N', '500');
    ins('10.2.X',  'plsql_optimize_level',            'Y', 'Y', 'N', 'N', '2');
    ins('10.2.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'INTERPRETED');
    ins('10.2.X',  'plsql_native_library_dir',        'Y', 'N', 'N', 'N', '?/prod11i/plsql_nativelib (if using NATIVE PL/SQL)');
    ins('10.2.X',  'plsql_native_library_subdir_count', 'Y', 'N', 'N', 'N', '149 (if using NATIVE PL/SQL)');
    ins('10.2.X',  '_b_tree_bitmap_plans',            'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('10.2.X',  'optimizer_secure_view_merging',   'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('10.2.X',  '_kks_use_mutex_pin',              'Y', 'N', 'N', 'N', 'FALSE (only HP-UX PA-RISC)');
    ins('10.2.X',  'aq_tm_processes',                 'Y', 'N', 'N', 'N', '1');
    /* Removal list for 10gR2 (10.2.X) */
    ins('10.2.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_kks_use_mutex_pin',              'N', 'N', 'N', 'N', 'Unless using HP-UX PA-RISC');
    ins('10.2.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'db_file_multiblock_read_count',   'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'enqueue_resources',               'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'undo_retention',                  'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    /* Release-specific database initialization parameters for 11gR1 (11.1.X) */
    ins('11.1.X',  'compatible',                      'Y', 'Y', 'N', 'N', '11.1.0');
    ins('11.1.X',  'diagnostic_dest',                 'Y', 'N', 'N', 'N', '?/prod11i');
    ins('11.1.X',  'sga_target',                      'Y', 'N', 'Y', 'N', '1-14G');
    ins('11.1.X',  'shared_pool_size',                'Y', 'N', 'Y', 'N', '400-3000M');
    ins('11.1.X',  'shared_pool_reserved_size',       'Y', 'N', 'Y', 'N', '40-300M');
    ins('11.1.X',  'nls_length_semantics',            'Y', 'Y', 'N', 'N', 'BYTE');
    ins('11.1.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('11.1.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('11.1.X',  'pga_aggregate_target',            'Y', 'N', 'Y', 'Y', '1-20G');
    ins('11.1.X',  'workarea_size_policy',            'Y', 'Y', 'N', 'Y', 'AUTO');
    ins('11.1.X',  'olap_page_pool_size',             'Y', 'N', 'N', 'N', '4194304');
    ins('11.1.X',  'open_cursors',                    'Y', 'N', 'N', 'N', '600');
    ins('11.1.X',  'session_cached_cursors',          'Y', 'N', 'N', 'N', '500');
    ins('11.1.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'NATIVE (if you want to use NATIVE compilation)');
    ins('11.1.X',  '_b_tree_bitmap_plans',            'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('11.1.X',  'optimizer_secure_view_merging',   'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('11.1.X',  '_optimizer_autostats_job',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('11.1.X',  'sec_case_sensitive_logon',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('11.1.X',  'aq_tm_processes',                 'Y', 'N', 'N', 'N', '1');
    /* Removal list for 11gR1 (11.1.X) */
    ins('11.1.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_kks_use_mutex_pin',              'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_sqlexec_progression_cost',       'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'background_dump_dest',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'core_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'db_file_multiblock_read_count',   'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'enqueue_resources',               'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'nls_language',                    'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'plsql_optimize_level',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'plsql_native_library_dir',        'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'plsql_native_library_subdir_count', 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'rollback_segments',               'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'sql_trace',                       'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'timed_statistics',                'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'undo_retention',                  'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'user_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    /* Release-specific database initialization parameters for 11gR2 (11.2.X) */
    ins('11.2.X',  'compatible',                      'Y', 'Y', 'N', 'N', '11.2.0');
    ins('11.2.X',  'diagnostic_dest',                 'Y', 'N', 'N', 'N', '?/prod11i');
    ins('11.2.X',  'sga_target',                      'Y', 'N', 'Y', 'N', '1-14G');
    ins('11.2.X',  'shared_pool_size',                'Y', 'N', 'Y', 'N', '400-3000M');
    ins('11.2.X',  'shared_pool_reserved_size',       'Y', 'N', 'Y', 'N', '40-300M');
    ins('11.2.X',  'nls_length_semantics',            'Y', 'Y', 'N', 'N', 'BYTE');
    ins('11.2.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('11.2.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('11.2.X',  'pga_aggregate_target',            'Y', 'N', 'Y', 'Y', '1-20G');
    ins('11.2.X',  'workarea_size_policy',            'Y', 'Y', 'N', 'Y', 'AUTO');
    ins('11.2.X',  'olap_page_pool_size',             'Y', 'N', 'N', 'N', '4194304');
    ins('11.2.X',  'open_cursors',                    'Y', 'N', 'N', 'N', '600');
    ins('11.2.X',  'session_cached_cursors',          'Y', 'N', 'N', 'N', '500');
    ins('11.2.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'NATIVE (if you want to use NATIVE compilation)');
    ins('11.2.X',  '_b_tree_bitmap_plans',            'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('11.2.X',  'optimizer_secure_view_merging',   'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('11.2.X',  '_optimizer_autostats_job',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('11.2.X',  'sec_case_sensitive_logon',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('11.2.X',  'aq_tm_processes',                 'Y', 'N', 'N', 'N', '1');
    /* Removal list for 11gR2 (11.2.X) */
    ins('11.2.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_kks_use_mutex_pin',              'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_sqlexec_progression_cost',       'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'background_dump_dest',            'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'core_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'db_file_multiblock_read_count',   'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'enqueue_resources',               'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'nls_language',                    'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'plsql_optimize_level',            'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'plsql_native_library_dir',        'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'plsql_native_library_subdir_count', 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'rollback_segments',               'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'sql_trace',                       'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'timed_statistics',                'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'undo_retention',                  'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'user_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'drs_start',                       'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'sql_version',                     'N', 'N', 'N', 'N', NULL);
    
    /* Release-specific database initialization parameters for 12cR1 (12.1.X) */
    ins('12.1.X',  'compatible',                      'Y', 'Y', 'N', 'N', '12.1.0'); -- changed in 12cR1
    ins('12.1.X',  'diagnostic_dest',                 'Y', 'N', 'N', 'N', '?/prod11i');
    ins('12.1.X',  'sga_target',                      'Y', 'N', 'Y', 'N', '1-14G');
    ins('12.1.X',  'shared_pool_size',                'Y', 'N', 'Y', 'N', '400-3000M');
    ins('12.1.X',  'shared_pool_reserved_size',       'Y', 'N', 'Y', 'N', '40-300M');
    ins('12.1.X',  'nls_length_semantics',            'Y', 'Y', 'N', 'N', 'BYTE');
    ins('12.1.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('12.1.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('12.1.X',  'pga_aggregate_target',            'Y', 'N', 'Y', 'Y', '1-20G');
    ins('12.1.X',  'workarea_size_policy',            'Y', 'Y', 'N', 'Y', 'AUTO');
    ins('12.1.X',  'olap_page_pool_size',             'Y', 'N', 'N', 'N', '4194304');
    ins('12.1.X',  'open_cursors',                    'Y', 'N', 'N', 'N', '600');
    ins('12.1.X',  'session_cached_cursors',          'Y', 'N', 'N', 'N', '500');
    ins('12.1.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'NATIVE (if you want to use NATIVE compilation)');
    ins('12.1.X',  '_b_tree_bitmap_plans',            'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('12.1.X',  'optimizer_secure_view_merging',   'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('12.1.X',  '_optimizer_autostats_job',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('12.1.X',  'parallel_force_local',            'Y', 'Y', 'N', 'Y', 'TRUE');  -- new in 12cR1
    ins('12.1.X',  'pga_aggregate_limit',             'Y', 'N', 'Y', 'Y', '0');     -- new in 12cR1
    ins('12.1.X',  'temp_undo_enabled',               'Y', 'N', 'N', 'Y', 'TRUE');  -- new in 12cR1
    ins('12.1.X',  'sec_case_sensitive_logon',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('12.1.X',  'aq_tm_processes',                 'Y', 'N', 'N', 'N', '1');
    /* Removal list for 12cR1 (12.1.X) */
    ins('12.1.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_kks_use_mutex_pin',              'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_sqlexec_progression_cost',       'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'background_dump_dest',            'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'core_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'db_file_multiblock_read_count',   'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'enqueue_resources',               'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'nls_language',                    'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'plsql_optimize_level',            'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'plsql_native_library_dir',        'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'plsql_native_library_subdir_count', 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'rollback_segments',               'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'sql_trace',                       'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'timed_statistics',                'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'undo_retention',                  'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'user_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'drs_start',                       'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'sql_version',                     'N', 'N', 'N', 'N', NULL);
    
  ELSIF p_apps_release LIKE '12%' THEN
    /*  version    name                               set  mp   sz   cbo  value                               */
    /*  ========== =============================      ===  ===  ===  ===  =================================== */
    ins('COMMON',  'db_name',                         'Y', 'N', 'N', 'N', 'prodr12');
    ins('COMMON',  'control_files',                   'Y', 'N', 'N', 'N', 'three copies of control file');
    ins('COMMON',  'db_block_size',                   'Y', 'Y', 'N', 'N', '8192');
    ins('COMMON',  '_system_trig_enabled',            'Y', 'Y', 'N', 'N', 'TRUE');
    ins('COMMON',  'o7_dictionary_accessibility',     'Y', 'Y', 'N', 'N', 'FALSE');
    ins('COMMON',  'nls_language',                    'Y', 'N', 'N', 'N', 'AMERICAN');
    ins('COMMON',  'nls_territory',                   'Y', 'N', 'N', 'N', 'AMERICA');
    ins('COMMON',  'nls_date_format',                 'Y', 'Y', 'N', 'N', 'DD-MON-RR');
    ins('COMMON',  'nls_numeric_characters',          'Y', 'N', 'N', 'N', '".,"');
    ins('COMMON',  'nls_sort',                        'Y', 'Y', 'N', 'N', 'BINARY');
    ins('COMMON',  'nls_comp',                        'Y', 'Y', 'N', 'N', 'BINARY');
    ins('COMMON',  'nls_length_semantics',            'Y', 'Y', 'N', 'N', 'BYTE');
    ins('COMMON',  'audit_trail',                     'Y', 'N', 'N', 'N', 'TRUE (optional)');
    ins('COMMON',  'user_dump_dest',                  'Y', 'N', 'N', 'N', '/ebiz/prodr12/udump');
    ins('COMMON',  'background_dump_dest',            'Y', 'N', 'N', 'N', '/ebiz/prodr12/bdump');
    ins('COMMON',  'core_dump_dest',                  'Y', 'N', 'N', 'N', '/ebiz/prodr12/cdump');
    ins('COMMON',  'max_dump_file_size',              'Y', 'N', 'N', 'N', '20480');
    ins('COMMON',  '_trace_files_public',             'Y', 'N', 'N', 'N', 'TRUE');
    ins('COMMON',  'processes',                       'Y', 'N', 'Y', 'N', '200-2500');
    ins('COMMON',  'sessions',                        'Y', 'N', 'Y', 'N', '400-5000');
    ins('COMMON',  'db_files',                        'Y', 'N', 'N', 'N', '512');
    ins('COMMON',  'dml_locks',                       'Y', 'N', 'N', 'N', '10000');
    ins('COMMON',  'cursor_sharing',                  'Y', 'Y', 'N', 'Y', 'EXACT');
    ins('COMMON',  'open_cursors',                    'Y', 'N', 'N', 'N', '600');
    ins('COMMON',  'session_cached_cursors',          'Y', 'N', 'N', 'N', '500');
    ins('COMMON',  'sga_target',                      'Y', 'N', 'Y', 'N', '2-14G');
    ins('COMMON',  'db_block_checking',               'Y', 'N', 'N', 'N', 'FALSE');
    ins('COMMON',  'db_block_checksum',               'Y', 'N', 'N', 'N', 'TRUE');
    ins('COMMON',  'log_checkpoint_timeout',          'Y', 'N', 'N', 'N', '1200');
    ins('COMMON',  'log_checkpoint_interval',         'Y', 'N', 'N', 'N', '100000');
    ins('COMMON',  'log_buffer',                      'Y', 'N', 'N', 'N', '10485760');
    ins('COMMON',  'log_checkpoints_to_alert',        'Y', 'N', 'N', 'N', 'TRUE');
    ins('COMMON',  'shared_pool_size',                'Y', 'N', 'Y', 'N', '600-3000M');
    ins('COMMON',  'shared_pool_reserved_size',       'Y', 'N', 'Y', 'N', '60-300M');
    ins('COMMON',  '_shared_pool_reserved_min_alloc', 'Y', 'N', 'N', 'N', '4100');
    ins('COMMON',  'cursor_space_for_time',           'Y', 'N', 'N', 'N', 'FALSE (default)');
    ins('COMMON',  'utl_file_dir',                    'Y', 'N', 'N', 'N', '/ebiz/prodr12/utl_file_dir');
    ins('COMMON',  'aq_tm_processes',                 'Y', 'N', 'N', 'N', '1');
    ins('COMMON',  'job_queue_processes',             'Y', 'N', 'N', 'N', '2');
    ins('COMMON',  'log_archive_start',               'Y', 'N', 'N', 'N', 'TRUE (optional)');
    ins('COMMON',  'parallel_max_servers',            'Y', 'N', 'N', 'N', '8 (up to 2*CPUs)');
    ins('COMMON',  'parallel_min_servers',            'Y', 'N', 'N', 'N', '0');
    ins('COMMON',  '_sort_elimination_cost_ratio',    'Y', 'Y', 'N', 'Y', '5');
    ins('COMMON',  '_like_with_bind_as_equality',     'Y', 'Y', 'N', 'Y', 'TRUE');
    ins('COMMON',  '_fast_full_scan_enabled',         'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('COMMON',  '_b_tree_bitmap_plans',            'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('COMMON',  'optimizer_secure_view_merging',   'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('COMMON',  '_sqlexec_progression_cost',       'Y', 'Y', 'N', 'Y', '2147483647');
    ins('COMMON',  'cluster_database',                'Y', 'Y', 'N', 'N', 'TRUE (if using RAC)');
    ins('COMMON',  'instance_groups',                 'Y', 'N', 'N', 'N', 'appsN (N is inst_id if using RAC)');
    ins('COMMON',  'parallel_instance_group',         'Y', 'N', 'N', 'N', 'appsN (N is inst_id if using RAC)');
    ins('COMMON',  'pga_aggregate_target',            'Y', 'N', 'Y', 'Y', '1-20G');
    ins('COMMON',  'workarea_size_policy',            'Y', 'Y', 'N', 'Y', 'AUTO');
    ins('COMMON',  'olap_page_pool_size',             'Y', 'N', 'N', 'N', '4194304');
    /* Release-specific database initialization parameters for 10gR2 (10.2.X) */
    ins('10.2.X',  'compatible',                      'Y', 'Y', 'N', 'N', '10.2.0');
    ins('10.2.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('10.2.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('10.2.X',  'plsql_optimize_level',            'Y', 'Y', 'N', 'N', '2');
    ins('10.2.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'NATIVE');
    ins('10.2.X',  'plsql_native_library_dir',        'Y', 'N', 'N', 'N', '/ebiz/prodr12/plsql_nativelib');
    ins('10.2.X',  'plsql_native_library_subdir_count', 'Y', 'N', 'N', 'N', '149');
    ins('10.2.X', '_kks_use_mutex_pin',               'Y', 'N', 'N', 'N', 'TRUE (FALSE only on HP-UX PA-RISC)');
    /* Removal list for 10gR2 (10.2.X) */
    ins('10.2.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'db_file_multiblock_read_count',   'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'enqueue_resources',               'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('10.2.X',  'undo_retention',                  'N', 'N', 'N', 'N', NULL);
    ins('10.2.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    /* Release-specific database initialization parameters for 11gR1 (11.1.X) */
    ins('11.1.X',  'compatible',                      'Y', 'Y', 'N', 'N', '11.1.0');
    ins('11.1.X',  'diagnostic_dest',                 'Y', 'N', 'N', 'N', '?/prod12');
    ins('11.1.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('11.1.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('11.1.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'NATIVE');
    ins('11.1.X',  '_optimizer_autostats_job',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('11.1.X',  'sec_case_sensitive_logon',        'Y', 'Y', 'N', 'N', 'FALSE');
    /* Removal list for 11gR1 (11.1.X) */
    ins('11.1.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_kks_use_mutex_pin',              'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_sqlexec_progression_cost',       'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'background_dump_dest',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'core_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'db_file_multiblock_read_count',   'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'enqueue_resources',               'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'nls_language',                    'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'plsql_optimize_level',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'plsql_native_library_dir',        'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'plsql_native_library_subdir_count', 'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'plsql_optimize_level',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'rollback_segments',               'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.1.X',  'sql_trace',                       'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'timed_statistics',                'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'undo_retention',                  'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    ins('11.1.X',  'user_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    /* Release-specific database initialization parameters for 11gR2 (11.2.X) */
    ins('11.2.X',  'compatible',                      'Y', 'Y', 'N', 'N', '11.2.0');
    ins('11.2.X',  'diagnostic_dest',                 'Y', 'N', 'N', 'N', '?/prod12');
    ins('11.2.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('11.2.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('11.2.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'NATIVE');
    ins('11.2.X',  '_optimizer_autostats_job',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('11.2.X',  'sec_case_sensitive_logon',        'Y', 'Y', 'N', 'N', 'FALSE');
    /* Removal list for 11gR1 (11.2.X) */
    ins('11.2.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_kks_use_mutex_pin',              'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_sqlexec_progression_cost',       'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'background_dump_dest',            'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'core_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'db_file_multiblock_read_count',   'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'drs_start',                       'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'enqueue_resources',               'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'nls_language',                    'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'parallel_force_local',            'Y', 'Y', 'N', 'Y', 'TRUE (if using RAC)');
    ins('11.2.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'plsql_native_library_dir',        'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'plsql_native_library_subdir_count', 'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'plsql_optimize_level',            'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'rollback_segments',               'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('11.2.X',  'sql_trace',                       'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'sql_version',                     'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'timed_statistics',                'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'undo_retention',                  'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    ins('11.2.X',  'user_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    
    /* Release-specific database initialization parameters for 12cR1 (12.1.X) */
    ins('12.1.X',  'compatible',                      'Y', 'Y', 'N', 'N', '12.1.0'); -- changed in 12cR1
    ins('12.1.X',  'diagnostic_dest',                 'Y', 'N', 'N', 'N', '?/prod11i');
    ins('12.1.X',  'sga_target',                      'Y', 'N', 'Y', 'N', '1-14G');
    ins('12.1.X',  'shared_pool_size',                'Y', 'N', 'Y', 'N', '400-3000M');
    ins('12.1.X',  'shared_pool_reserved_size',       'Y', 'N', 'Y', 'N', '40-300M');
    ins('12.1.X',  'nls_length_semantics',            'Y', 'Y', 'N', 'N', 'BYTE');
    ins('12.1.X',  'undo_management',                 'Y', 'Y', 'N', 'N', 'AUTO');
    ins('12.1.X',  'undo_tablespace',                 'Y', 'Y', 'N', 'N', 'APPS_UNDOTS1');
    ins('12.1.X',  'pga_aggregate_target',            'Y', 'N', 'Y', 'Y', '1-20G');
    ins('12.1.X',  'workarea_size_policy',            'Y', 'Y', 'N', 'Y', 'AUTO');
    ins('12.1.X',  'olap_page_pool_size',             'Y', 'N', 'N', 'N', '4194304');
    ins('12.1.X',  'open_cursors',                    'Y', 'N', 'N', 'N', '600');
    ins('12.1.X',  'session_cached_cursors',          'Y', 'N', 'N', 'N', '500');
    ins('12.1.X',  'plsql_code_type',                 'Y', 'N', 'N', 'N', 'NATIVE (if you want to use NATIVE compilation)');
    ins('12.1.X',  '_b_tree_bitmap_plans',            'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('12.1.X',  'optimizer_secure_view_merging',   'Y', 'Y', 'N', 'Y', 'FALSE');
    ins('12.1.X',  '_optimizer_autostats_job',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('12.1.X',  'parallel_force_local',            'Y', 'Y', 'N', 'Y', 'TRUE');  -- new in 12cR1
    ins('12.1.X',  'pga_aggregate_limit',             'Y', 'N', 'Y', 'Y', '0');     -- new in 12cR1
    ins('12.1.X',  'temp_undo_enabled',               'Y', 'N', 'N', 'Y', 'TRUE');  -- new in 12cR1
    ins('12.1.X',  'sec_case_sensitive_logon',        'Y', 'Y', 'N', 'N', 'FALSE');
    ins('12.1.X',  'aq_tm_processes',                 'Y', 'N', 'N', 'N', '1');
    /* Removal list for 12cR1 (12.1.X) */
    ins('12.1.X',  '_always_anti_join',               'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_always_semi_join',               'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_complex_view_merging',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_index_join_enabled',             'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_kks_use_mutex_pin',              'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  '_new_initial_join_orders',        'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_optimizer_cost_based_transformation', 'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_optimizer_cost_model',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_optimizer_mode_force',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_optimizer_undo_changes',         'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_or_expand_nvl_predicate',        'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_ordered_nested_loop',            'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_push_join_predicate',            'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_push_join_union_view',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_shared_pool_reserved_min_alloc', 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  '_sortmerge_inequality_join_off',  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_sqlexec_progression_cost',       'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_table_scan_cost_plus_one',       'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_unnest_subquery',                'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  '_use_column_stats_for_function',  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'always_anti_join',                'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'always_semi_join',                'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'background_dump_dest',            'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'core_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'db_block_buffers',                'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'db_file_multiblock_read_count',   'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'db_cache_size',                   'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'enqueue_resources',               'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="10932 trace name context level 32768"',      'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="10933 trace name context level 512"',        'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="10943 trace name context forever, level 2"', 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="10943 trace name context level 16384"',      'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'event="38004 trace name context forever, level 1"', 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'hash_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'java_pool_size',                  'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'job_queue_interval',              'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'large_pool_size',                 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'max_enabled_roles',               'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'nls_language',                    'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'optimizer_dynamic_sampling',      'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_features_enable',       'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_index_caching',         'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_index_cost_adj',        'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_max_permutations',      'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_mode',                  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'optimizer_percent_parallel',      'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'plsql_optimize_level',            'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'plsql_compiler_flags',            'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'plsql_native_library_dir',        'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'plsql_native_library_subdir_count', 'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'query_rewrite_enabled',           'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'rollback_segments',               'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'row_locking',                     'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'sort_area_size',                  'N', 'N', 'N', 'Y', NULL);
    ins('12.1.X',  'sql_trace',                       'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'timed_statistics',                'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'undo_retention',                  'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'undo_suppress_errors',            'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'user_dump_dest',                  'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'drs_start',                       'N', 'N', 'N', 'N', NULL);
    ins('12.1.X',  'sql_version',                     'N', 'N', 'N', 'N', NULL);
      
  END IF;

  COMMIT;
END chk$ebs$parameters;
/
SHOW ERRORS;

TRUNCATE TABLE chk$cbo$parameter_apps;
EXEC chk$ebs$parameters(:v_rdbms_version, :v_apps_release);
DROP PROCEDURE chk$ebs$parameters;

/******************************************************************************/

SET ECHO OFF;
SPO bde_chk_cbo_report.html;
PRO <html>
PRO <!-- $Header: 174605.1 bde_chk_cbo.sql 12.1.04 2013/11/11 csierra $ -->
PRO <!-- Copyright (c) 2000-2012, Oracle Corporation. All rights reserved. -->
PRO <!-- AUTHOR: carlos.sierra@oracle.com -->
PRO <head>
PRO <title>bde_chk_cbo_report.html</title>
PRO <style type="text/css">
PRO body {font:8pt Arial,Helvetica,Verdana,Geneva,sans-serif; color:black; background:white;}
PRO a {font-weight:bold; color:#663300;}
PRO h1 {font-size:16pt; font-weight:bold; color:#336699;}
PRO h2 {font-size:14pt; font-weight:bold; color:#336699;}
PRO h3 {font-size:12pt; font-weight:bold; color:#336699;}
PRO table {font-size:8pt; color:black; background:white;}
PRO th {font-weight:bold; background:#cccc99; color:#336699; vertical-align:bottom; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td {background:#fcfcf0; vertical-align:top; padding-left:3pt; padding-right:3pt; padding-top:1pt; padding-bottom:1pt;}
PRO td.left {text-align:left;} /* left */
PRO td.right {text-align:right;} /* right */
PRO td.center {text-align:center;} /* center */
PRO td.title {font-weight:bold; color:#336699; background:#cccc99; text-align:right;} /* right title */
PRO font.footer {font-size:8pt; font-weight:italic; color:#999999;} /* footnote in gray */
PRO </style>
PRO </head>
PRO <body>
PRO <h1>174605.1 bde_chk_cbo 12.1.04</h1>
PRO <h3>Identification</h3>
PRO <table>
PRO <tr><td class="title">Date:</td><td class="left">&&p_sysdate</td></tr>
PRO <tr><td class="title">Host:</td><td class="left">&&p_host</td></tr>
PRO <tr><td class="title">Platform:</td><td class="left">&&p_platform</td></tr>
PRO <tr><td class="title">Database:</td><td class="left">&&p_database</td></tr>
PRO <tr><td class="title">Instance:</td><td class="left">&&p_instance</td></tr>
PRO <tr><td class="title">RDBMS Release:</td><td class="left">&&p_rdbms_release(&&p_rdbms_version)</td></tr>
PRO <tr><td class="title">User:</td><td class="left">&&p_user</td></tr>
PRO <tr><td class="title">APPS Release:</td><td class="left">&&p_apps_release</td></tr>
PRO <tr><td class="title">CPU Count:</td><td class="left">&&p_cpu_count</td></tr>
PRO </table>

/******************************************************************************/

PRO <h3>Common database initialization parameters</h3>
PRO <table>
PRO <tr>
PRO <th>Parameter</th>
PRO <th>Current Value</th>
PRO <th>Required Value</th>
PRO <th>CBO</th>
PRO <th>MP</th>
PRO <th>SZ</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||b.name||'</td>'||
'<td class="left">'||DECODE(v.name, NULL, '<i>(NOT FOUND)</i>', v.value||DECODE(v.isdefault, 'TRUE', ' <i>(NOT SET)</i>'))||'</td>'||
'<td class="left">'||DECODE(b.set_flag, 'N', '<i>DO NOT SET</i>', b.value)||'</td>'||
'<td class="center">'||DECODE(b.cbo_flag, 'Y', 'Y')||'</td>'||
'<td class="center">'||DECODE(b.mp_flag, 'Y', 'Y')||'</td>'||
'<td class="center">'||DECODE(b.sz_flag, 'Y', 'Y')||'</td>'||
'</tr>' line
FROM chk$cbo$parameter_apps b, v$parameter2 v
WHERE b.release = :v_apps_release
AND b.version = 'COMMON'
AND b.name = LOWER(v.name(+))
ORDER BY b.id, v.value;
PRO </table>
PRO CBO: Cost-based Optimizer Parameter.<br>
PRO MP: Mandatory Parameter and Value<br>
PRO SZ: For recommended values according to particular environment size, refer to Notes 216205.1 and 396009.1<br>

/******************************************************************************/

PRO <h3>Release-specific database initialization parameters for &&p_rdbms_version</h3>
PRO <table>
PRO <tr>
PRO <th>Parameter</th>
PRO <th>Current Value</th>
PRO <th>Required Value</th>
PRO <th>CBO</th>
PRO <th>MP</th>
PRO <th>SZ</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||b.name||'</td>'||
'<td class="left">'||DECODE(v.name, NULL, '<i>(NOT FOUND)</i>', v.value||DECODE(v.isdefault, 'TRUE', ' <i>(NOT SET)</i>'))||'</td>'||
'<td class="left">'||b.value||'</td>'||
'<td class="center">'||DECODE(b.cbo_flag, 'Y', 'Y')||'</td>'||
'<td class="center">'||DECODE(b.mp_flag, 'Y', 'Y')||'</td>'||
'<td class="center">'||DECODE(b.sz_flag, 'Y', 'Y')||'</td>'||
'</tr>' line
FROM chk$cbo$parameter_apps b, v$parameter2 v
WHERE b.release = :v_apps_release
AND b.version = :v_rdbms_version
AND b.name = LOWER(v.name(+))
AND b.set_flag = 'Y'
ORDER BY b.id, v.value;
PRO </table>
PRO CBO: Cost-based Optimizer Parameter.<br>
PRO MP: Mandatory Parameter and Value<br>
PRO SZ: For recommended values according to particular environment size, refer to Notes 216205.1 and 396009.1<br>

/******************************************************************************/

PRO <h3>Removal list for &&p_rdbms_version</h3>
PRO <table>
PRO <tr>
PRO <th>Parameter</th>
PRO <th>Current Value</th>
PRO <th>CBO</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||b.name||'</td>'||
--'<td class="left">'||NVL(DECODE(v.isdefault, 'TRUE', '<!--(NOT SET)-->', v.value), '<!--(NOT FOUND)-->')||'</td>'||
'<td class="left">'||NVL(DECODE(v.isdefault, 'TRUE', '<i><font color="gray">(NOT SET)</font></i><!--TRUE-->', v.value), '<i><font color="gray">(NOT SET)</font></i><!--NULL-->')||'</td>'||
'<td class="center">'||DECODE(b.cbo_flag, 'Y', 'Y')||'</td>'||
'</tr>' line
FROM chk$cbo$parameter_apps b, v$parameter2 v
WHERE b.release = :v_apps_release
AND b.version = :v_rdbms_version
AND b.name = LOWER(v.name(+))
AND b.set_flag = 'N'
ORDER BY b.id, v.value;
PRO </table>
PRO CBO: Cost-based Optimizer Parameter.<br>

/******************************************************************************/

PRO <h3>Additional initialization parameters with non-default values</h3>
PRO <table>
PRO <tr>
PRO <th>Parameter</th>
PRO <th>Current Value</th>
PRO </tr>
SELECT
'<tr>'||
'<td class="left">'||v.name||'</td>'||
'<td class="left">'||v.value||'</td>'||
'</tr>' line
FROM v$parameter2 v
WHERE v.isdefault = 'FALSE'
AND NOT EXISTS (SELECT NULL FROM chk$cbo$parameter_apps b WHERE b.name = LOWER(v.name))
ORDER BY v.name, v.value;
PRO </table>

/******************************************************************************/

PRO <br><hr size="1">
SELECT '<font class="footer">174605.1 bde_check_cbo 12.1.04 '||TO_CHAR(SYSDATE, 'DD-MON-YY HH24:MI')||'</font>' FROM DUAL;
PRO </body>
PRO </html>
SPO OFF

DROP TABLE chk$cbo$parameter_apps;

SET TERM ON;
PRO
PRO Spool file bde_chk_cbo_report.html has been generated.

/******************************************************************************/
