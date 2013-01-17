Col name format a50
Set feedback off
Prompt
Select a.name, b.value, b.value-&V diff
from v$statname a, v$mystat b
where a.statistic# = b.statistic#
and lower(a.name) like '%'||lower('&S')||'%'
/
Prompt
Set feedback on
