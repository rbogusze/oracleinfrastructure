-- Largest objects in DB
select owner, segment_name, segment_type, round(bytes/1024/1024/1024) SIZE_GB from dba_segments order by 4 desc;

select * from dba_lobs where owner = 'REFTECH';
select * from dba_segments where segment_name = 'SYS_LOB0000087857C00002$$';

select segment_name, round((bytes)/1024/1024/1024) SIZE_GB from dba_segments where segment_name = 'SYS_LOB0000087857C00002$$';



-- How to determine the actual size of the LOB segments and how to free the deleted/unused space above/below the HWM (Doc ID 386341.1)
select sum(dbms_lob.getlength (MFILE)) from REFTECH.TESTLOAD;

set serveroutput on 

declare 
TOTAL_BLOCKS number; 
TOTAL_BYTES number; 
UNUSED_BLOCKS number; 
UNUSED_BYTES number; 
LAST_USED_EXTENT_FILE_ID number; 
LAST_USED_EXTENT_BLOCK_ID number; 
LAST_USED_BLOCK number; 

begin 
dbms_space.unused_space('REFTECH','SYS_LOB0000087857C00002$$','LOB', 
TOTAL_BLOCKS, TOTAL_BYTES, UNUSED_BLOCKS, UNUSED_BYTES, 
LAST_USED_EXTENT_FILE_ID, LAST_USED_EXTENT_BLOCK_ID, 
LAST_USED_BLOCK); 

dbms_output.put_line('SEGMENT_NAME = <LOB SEGMENT NAME>'); 
dbms_output.put_line('-----------------------------------'); 
dbms_output.put_line('TOTAL_BLOCKS = '||TOTAL_BLOCKS); 
dbms_output.put_line('TOTAL_BYTES = '||TOTAL_BYTES); 
dbms_output.put_line('UNUSED_BLOCKS = '||UNUSED_BLOCKS); 
dbms_output.put_line('UNUSED BYTES = '||UNUSED_BYTES); 
dbms_output.put_line('LAST_USED_EXTENT_FILE_ID = '||LAST_USED_EXTENT_FILE_ID); 
dbms_output.put_line('LAST_USED_EXTENT_BLOCK_ID = '||LAST_USED_EXTENT_BLOCK_ID); 
dbms_output.put_line('LAST_USED_BLOCK = '||LAST_USED_BLOCK); 

end; 
/


declare 
v_unformatted_blocks number; 
v_unformatted_bytes number; 
v_fs1_blocks number; 
v_fs1_bytes number; 
v_fs2_blocks number; 
v_fs2_bytes number; 
v_fs3_blocks number; 
v_fs3_bytes number; 
v_fs4_blocks number; 
v_fs4_bytes number; 
v_full_blocks number; 
v_full_bytes number; 
begin 
dbms_space.space_usage ('REFTECH','SYS_LOB0000087857C00002$$', 'LOB', v_unformatted_blocks, 
v_unformatted_bytes, v_fs1_blocks, v_fs1_bytes, v_fs2_blocks, v_fs2_bytes, 
v_fs3_blocks, v_fs3_bytes, v_fs4_blocks, v_fs4_bytes, v_full_blocks, v_full_bytes); 
dbms_output.put_line('Unformatted Blocks = '||v_unformatted_blocks); 
dbms_output.put_line('FS1 Blocks = '||v_fs1_blocks); 
dbms_output.put_line('FS2 Blocks = '||v_fs2_blocks); 
dbms_output.put_line('FS3 Blocks = '||v_fs3_blocks); 
dbms_output.put_line('FS4 Blocks = '||v_fs4_blocks); 
dbms_output.put_line('Full Blocks = '||v_full_blocks); 
end; 
/

select * from dba_tablespaces;

select tablespace_name,EXTENT_MANAGEMENT,allocation_type,segment_space_management
from dba_tablespaces where segment_space_management='AUTO' 
and tablespace_name NOT LIKE '%UNDO%'
and tablespace_name = 'USERS'
/


