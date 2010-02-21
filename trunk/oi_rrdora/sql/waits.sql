set pages 0
set lines 2000
set trimspool on
set feedback off
set serveroutput on
declare
 cursor c_wait is
  select event, time_waited from v$system_event;

 t_w01     number (38) := 0;
 t_w02     number (38) := 0;
 t_w03     number (38) := 0;
 t_w04     number (38) := 0;
 t_w05     number (38) := 0;
 t_w06     number (38) := 0;
 t_w07     number (38) := 0;
 t_w08     number (38) := 0;
 t_w09     number (38) := 0;
 t_w10     number (38) := 0;
 t_w11     number (38) := 0;
 t_w12     number (38) := 0;
 t_w13     number (38) := 0;
 t_w14     number (38) := 0;
 t_w15     number (38) := 0;
 t_w16     number (38) := 0;
 t_w17     number (38) := 0;

begin
 dbms_output.enable(650000);
 for r_wait in c_wait
 loop
  -- wait event 01 buffer busy waits
  if r_wait.event = 'buffer busy waits'             then t_w01 := r_wait.time_waited; end if;

  -- wait event 02 control file IO
  if r_wait.event = 'control file parallel write'   then t_w02 := t_w02 + r_wait.time_waited; end if;
  if r_wait.event = 'control file sequential read'  then t_w02 := t_w02 + r_wait.time_waited; end if;
  if r_wait.event = 'control file single write'     then t_w02 := t_w02 + r_wait.time_waited; end if;

  -- wait event 03 db file parallel read
  if r_wait.event = 'db file parallel read'         then t_w03 := r_wait.time_waited; end if;

  -- wait event 04 db file scattered read
  if r_wait.event = 'db file scattered read'        then t_w04 := r_wait.time_waited; end if;

  -- wait event 05 db file sequential read
  if r_wait.event = 'db file sequential read'       then t_w05 := r_wait.time_waited; end if;

  -- wait event 06 db file parallel write
  if r_wait.event = 'db file parallel write'        then t_w06 := r_wait.time_waited; end if;

  -- wait event 07 db file single write
  if r_wait.event = 'db file single write'          then t_w07 := r_wait.time_waited; end if;

  -- wait event 08 direct path IO
  if r_wait.event = 'direct path read'              then t_w08 := t_w08 + r_wait.time_waited; end if;
  if r_wait.event = 'direct path write'             then t_w08 := t_w08 + r_wait.time_waited; end if;

  -- wait event 09 free buffer waits
  if r_wait.event = 'free buffer waits'             then t_w09 := r_wait.time_waited; end if;

  -- wait event 10 latch free
  if r_wait.event = 'latch free'                    then t_w10 := r_wait.time_waited; end if;

  -- wait event 11 log buffer space
  if r_wait.event = 'log buffer space'              then t_w11 := r_wait.time_waited; end if;

  -- wait event 12 log file parallel write
  if r_wait.event = 'log file parallel write'       then t_w12 := r_wait.time_waited; end if;

  -- wait event 13 log file sequential read
  if r_wait.event = 'log file sequential read'      then t_w13 := r_wait.time_waited; end if;

  -- wait event 14 log file single write
  if r_wait.event = 'log file single write'         then t_w14 := r_wait.time_waited; end if;

  -- wait event 15 log file switch completion
  if r_wait.event = 'log file switch completion'    then t_w15 := r_wait.time_waited; end if;

  -- wait event 16 log file sync
  if r_wait.event = 'log file sync'                 then t_w16 := r_wait.time_waited; end if;

  -- wait event 17 SQL Net
  if r_wait.event = 'SQL*Net message to client'     then t_w17 := t_w17 + r_wait.time_waited; end if;
  if r_wait.event = 'SQL*Net more data from client' then t_w17 := t_w17 + r_wait.time_waited; end if;
  if r_wait.event = 'SQL*Net more data to client'   then t_w17 := t_w17 + r_wait.time_waited; end if;
 end loop;
  dbms_output.put_line('N:'||
                      t_w01||':'||
                      t_w02||':'||
                      t_w03||':'||
                      t_w04||':'||
                      t_w05||':'||
                      t_w06||':'||
                      t_w07||':'||
                      t_w08||':'||
                      t_w09||':'||
                      t_w10||':'||
                      t_w11||':'||
                      t_w12||':'||
                      t_w13||':'||
                      t_w14||':'||
                      t_w15||':'||
                      t_w16||':'||
                      t_w17);
end;
/
