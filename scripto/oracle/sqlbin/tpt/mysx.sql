select
  n.statistic# stat#,
  n.statistic# * 8 offset,
  n.name,
  s.value,
  to_char(s.value, 'XXXXXXXXXXXXXXXX')  value_hex
from v$mystat s, v$statname n
where s.statistic#=n.statistic#
and lower(n.name) like lower('%&1%')
and rownum <= &2
/

