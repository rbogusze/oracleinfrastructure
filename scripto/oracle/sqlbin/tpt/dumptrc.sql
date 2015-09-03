alter session set tracefile_identifier = &1;
alter session set events 'immediate trace name &1';
alter session set tracefile_identifier = '';
