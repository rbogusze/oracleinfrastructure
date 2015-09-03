col syn_db_link head DB_LINK for a30

select
	owner,
	synonym_name,
	table_owner,
	table_name,
	db_link syn_db_link
from dba_synonyms where lower(synonym_name) like lower('&1')
/
