set termout off

begin
	begin
		sys.dbms_logmnr.end_logmnr;
	exception
		when others then null;
	end;

	sys.dbms_logmnr.add_logfile('&1');
	sys.dbms_logmnr.start_logmnr ( options => dbms_logmnr.dict_from_online_catalog );
end;
/

set termout on
