prompt Show tablespace fill ratio that takes under account the autoextend
prompt That is what Nagios is monitoring and it may be that we have a lot of free space in tablespaces but still we see the warning
select tablespace_name, round(sum(blocks*8192/1024/1024)) UsedMB, round(sum(maxblocks*8192/1024/1024)) MaxMB, round(sum(blocks)*100/sum(maxblocks)) rate from dba_data_files where maxblocks > 0 group by tablespace_name order by rate;
