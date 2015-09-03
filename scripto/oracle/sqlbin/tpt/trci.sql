set termout off

column trci_cmd new_value trci_cmd 
select decode(lower('&1'),'off','''''','&1') trci_cmd from dual;
column trci_cmd clear

set termout on

alter session set tracefile_identifier = &trci_cmd;

