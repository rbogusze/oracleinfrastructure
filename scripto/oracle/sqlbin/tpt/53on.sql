prompt alter session set events '10053 trace name context forever, level 1';;
prompt alter session set "_optimizer_trace"=all;;

alter session set events '10053 trace name context forever, level 1';
alter session set "_optimizer_trace"=all;
