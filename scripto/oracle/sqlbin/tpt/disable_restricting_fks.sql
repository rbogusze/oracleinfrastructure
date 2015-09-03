select 'alter table '||table_name||' disable constraint '||constraint_name||';'
from user_constraints
where constraint_name in (select a.constraint_name 
                          from user_constraints a, user_constraints b
                          where a.r_constraint_name = b.constraint_name
                          and b.table_name = '&1'
                          and a.constraint_type = 'R');
