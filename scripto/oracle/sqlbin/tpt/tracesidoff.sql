declare
    l_sid    number;
    l_serial number;
begin

    select sid, serial# 
    into l_sid, l_serial
    from v$session 
    where sid = &1;

    sys.dbms_monitor.session_trace_disable(l_sid,l_serial);  

end;
/
