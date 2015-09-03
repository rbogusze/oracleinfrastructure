declare
    procedure p is
        pragma autonomous_transaction;
    begin
	begin
              insert into t values(1);
--              set transaction read only;
              dbms_lock.sleep(1);
--        exception
--            when others then null;
        end;
	p;
    end;

begin
    p;
end;
/
