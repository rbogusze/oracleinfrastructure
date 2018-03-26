set serveroutput on
declare
   v_unformatted_blocks number;
   v_unformatted_bytes  number;
   v_fs1_blocks         number;
   v_fs1_bytes          number;
   v_fs2_blocks         number;
   v_fs2_bytes          number;
   v_fs3_blocks         number;
   v_fs3_bytes          number;
    v_fs4_blocks         number;
    v_fs4_bytes          number;
    v_full_blocks        number;
    v_full_bytes         number;
  begin
    dbms_space.space_usage(
      segment_owner=>'REFTECH', segment_name=>'TEST', segment_type=>'TABLE',
      unformatted_blocks=>v_unformatted_blocks, unformatted_bytes=>v_unformatted_bytes,
      fs1_blocks=>v_fs1_blocks, fs1_bytes=>v_fs1_bytes,
      fs2_blocks=>v_fs2_blocks, fs2_bytes=>v_fs2_bytes,
      fs3_blocks=>v_fs3_blocks, fs3_bytes=>v_fs3_bytes,
      fs4_blocks=>v_fs4_blocks, fs4_bytes=>v_fs4_bytes,
      full_blocks=>v_full_blocks, full_bytes=>v_full_bytes
    );
    dbms_output.put_line('Unformatted Blocks = '||v_unformatted_blocks);
    dbms_output.put_line('0 - 25% free blocks= '||v_fs1_blocks);
    dbms_output.put_line('25- 50% free blocks= '||v_fs2_blocks);
    dbms_output.put_line('50- 75% free blocks= '||v_fs3_blocks);
    dbms_output.put_line('75-100% free blocks= '||v_fs4_blocks);
    dbms_output.put_line('Full Blocks        = '||v_full_blocks);

    dbms_output.put_line('0 - 25% Bytes= '||v_fs1_bytes);
    dbms_output.put_line('25- 50% Bytes= '||v_fs2_bytes);
    dbms_output.put_line('50- 75% Bytes= '||v_fs3_bytes);
    dbms_output.put_line('75-100% Bytes= '||v_fs4_bytes);
    dbms_output.put_line('Full Bytes         = '||v_full_bytes);

  end;
/