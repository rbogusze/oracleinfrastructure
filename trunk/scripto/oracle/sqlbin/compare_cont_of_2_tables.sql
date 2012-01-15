rem Comparing Contents of Two Tables with Identical Structure
rem http://www.oracle.com/technology/oramag/code/tips2003/122103.html
rem see also http://www.oracle.com/technology/oramag/code/tips2004/012504.html

undefine TABLE1
undefine TABLE2
define g_table1 = '&&TABLE1'
define g_table2 = '&&TABLE2'
set verify off
set feedback off
set serveroutput on size 1000000
spo temp_file.sql
declare
v_owntab1 varchar2(255) := '&&g_table1';
v_owntab2 varchar2(255) := '&&g_table2';
v_own1 varchar2(255);
v_own2 varchar2(255);
v_tab1 varchar2(255);
v_tab2 varchar2(255);
v_dot1 number := 0;
v_dot2 number := 0;
type t_cols is table of varchar2(255) index by binary_integer; v_cols1
t_cols; v_cols2 t_cols; v_out1 varchar2(255); v_out2 varchar2(255); kq
CONSTANT varchar2(1) := ''''; v_ind number := 0; v_str
varchar2(2000):=null; v_ind_found boolean := FALSE; v_ind_colno number
:= 0;
  procedure print_cols (p_cols in t_cols) is
  begin
  for i in 1..p_cols.count
  loop
    dbms_output.put_line(','||p_cols(i));
  end loop;
  end print_cols;

begin
  v_dot1 := instr(v_owntab1, '.');
  v_dot2 := instr(v_owntab2, '.');

  if v_dot1 > 0 then
    v_own1 := upper(substr(v_owntab1, 1, v_dot1-1));
    v_tab1 := upper(substr(v_owntab1, v_dot1+1));
  else
    v_own1 := null;
    v_tab1 := upper(v_owntab1);
  end if;

  if v_dot2 > 0 then
    v_own2 := upper(substr(v_owntab2, 1, v_dot2-1));
    v_tab2 := upper(substr(v_owntab2, v_dot2+1));
  else
    v_own2 := null;
    v_tab2 := upper(v_owntab2);
  end if;
  select column_name
  bulk collect into v_cols1
  from all_tab_columns
  where table_name = v_tab1
  and owner = nvl(v_own1, user)
  order by column_id;

  select column_name
  bulk collect into v_cols2
  from all_tab_columns
  where table_name = v_tab2
  and owner = nvl(v_own2, user)
  order by column_id;

  if v_cols1.count = 0 or v_cols2.count = 0 then
    dbms_output.put_line('Either or Both the tables are invalid');
    return;
  end if;

  dbms_output.put_line('(');
  dbms_output.put_line('select '||kq||'TAB1'||kq);
  print_cols(v_cols1);
  dbms_output.put_line(' from '||nvl(v_own1, user)||'.'||v_tab1);
  dbms_output.put_line('MINUS');
  dbms_output.put_line('select '||kq||'TAB1'||kq);
  print_cols(v_cols1);
  dbms_output.put_line(' from '||nvl(v_own2, user)||'.'||v_tab2);
  dbms_output.put_line(')');

  dbms_output.put_line('UNION');

  dbms_output.put_line('(');
  dbms_output.put_line('select '||kq||'TAB2'||kq);
  print_cols(v_cols1);
  dbms_output.put_line(' from '||nvl(v_own2, user)||'.'||v_tab2);
  dbms_output.put_line('MINUS');
  dbms_output.put_line('select '||kq||'TAB2'||kq);
  print_cols(v_cols1);
  dbms_output.put_line(' from '||nvl(v_own1, user)||'.'||v_tab1);
  dbms_output.put_line(')');

  dbms_output.put_line('order by ');
  for c1 in (
  select b.column_name
  from all_indexes a, all_ind_columns b
  where a.owner=b.index_owner
  and a.index_name=b.index_name
  and a.uniqueness = 'UNIQUE'
  and a.table_owner = nvl(v_own1, user)
  and a.table_name = v_tab1
  order by b.index_name, b.column_position
  )
  loop
    v_ind_found := TRUE;
    v_ind_colno := v_ind_colno + 1;
    if v_ind_colno = 1 then
      dbms_output.put_line(c1.column_name);
    else
      dbms_output.put_line(','||c1.column_name);
    end if;
  end loop;
  if not v_ind_found then
    dbms_output.put_line('2 ');
  end if;
  dbms_output.put_line(';');


end;
/
spo off
set feedback on

