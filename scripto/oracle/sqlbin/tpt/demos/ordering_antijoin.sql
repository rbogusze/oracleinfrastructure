SELECT * FROM (
	select rownum r from 
	all_users where username like 'S%'
	order by r desc
)
WHERE r NOT IN (select /*+ HASH_AJ(a) */ rownum FROM all_users a where rownum<= 2)
and rownum <= 5
/

