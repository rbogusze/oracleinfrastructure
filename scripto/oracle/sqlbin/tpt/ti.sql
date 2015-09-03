@@saveset

column _ti_sequence noprint new_value _ti_sequence

set feedback off heading off

select trim(to_char( &_ti_sequence + 1 , '0999' )) "_ti_sequence" from dual;

alter session set tracefile_identifier="&_ti_sequence";

set feedback on heading on

set termout off

column tracefile noprint new_value trc

	select value ||'/'||(select instance_name from v$instance) ||'_ora_'||
	       (select spid||case when traceid is not null then '_'||traceid else null end
                from v$process where addr = (select paddr from v$session
	                                         where sid = (select sid from v$mystat
	                                                    where rownum = 1
	                                               )
	                                    )
	       ) || '.trc' tracefile
	from v$parameter where name = 'user_dump_dest';

set termout on
@@loadset

prompt New tracefile_identifier=&trc

col tracefile clear

