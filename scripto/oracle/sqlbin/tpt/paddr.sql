select * from v$process where addr = hextoraw(upper('&1'));
