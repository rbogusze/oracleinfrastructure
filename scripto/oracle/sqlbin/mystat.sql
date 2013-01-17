Column value new_val V
Define S="&1"
Col name format a50
Set feedback off
Prompt
Select a.name, b.value
from v$statname a, v$mystat b
where a.statistic# = b.statistic#
and lower(a.name) like '%'||lower('&S')||'%'
/
Prompt
Set feedback on
