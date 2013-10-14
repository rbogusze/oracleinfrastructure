REM ======================================================================
REM hout.sql		Version 1.1	29 Dec 2000
REM
REM Purpose:
REM	To provide an output package for the h*.sql series of scripts.
REM 	All h*.sql scripts use this package to output their results
REM	This allows one package to control where output is sent
REM	to. 
REM	Eg: This package can be coded to output to DBMS_OUTPUT
REM	    or to use the UTL_FILE calls if required.
REM
REM	This version of the script can write to both DBMS_OUTPUT and
REM	to the users trace file.
REM 
REM Usage:
REM     See Note:101466.1 for details of using this and other h* packages
REM
REM Depends on:
REM	dbms_output , dbms_system
REM
REM Notes:
REM 	Must be installed in SYS schema
REM	For Oracle 7.3, 8.0, 8.1, 9.0, 9.2, 10.1, 10.2, 11.1 and 11.2 
REM 	server versions
REM
REM CAUTION
REM   The sample program in this article is provided for educational 
REM   purposes only and is NOT supported by Oracle Support Services.  
REM   It has been tested internally, however, and works as documented.  
REM   We do not guarantee that it will work for you, so be sure to test 
REM   it in your environment before relying on it.
REM 
REM ======================================================================
REM
create or replace package hOut as
 -- 
 -- Output options - change these to default as required
 -- You can override them at run time if required.
 --
  TO_DBMS_OUTPUT boolean := TRUE;	-- Send output to DBMS_OUTPUT
  TO_USER_TRACE  boolean := TRUE;	-- Send output to user trace file
  IGNORE_ERRORS  boolean := TRUE;	-- Ignore DBMS_OUTPUT errors if
					-- also writing to the trace file
 --
 -- Output methods
 --
  procedure put_line(txt varchar2);
  procedure put(txt varchar2);
  procedure new_line;
  procedure wrap(txt varchar2, linelen number default 78);
  procedure rule_off;
 --
end hOut;
/
show errors
create or replace package body hOut as
  -- 7.3 has problems with ksdwrt as it uses the wrong length info
  -- putting nonsense on the end of lines.
  -- As a workaround we copy the text to a TMP varchar, append a chr(0)
  -- then reset the length back so we have an hidden chr(0) at the end
  -- of the string.
  tmp varchar2(2001);
  --
  APP_EXCEPTION EXCEPTION;
  pragma exception_init(APP_EXCEPTION, -20000);
  --
  procedure put_line(txt varchar2) is
  begin
    tmp:=txt||chr(0);
    tmp:=txt;
    if TO_DBMS_OUTPUT then
      begin
	dbms_output.put_line(txt);
      exception
	when APP_EXCEPTION then
	  -- If DBMS_OUTPUT is full then carry on if we are writing to
	  -- the trace file and ignoring errors, otherwise error now
	  if TO_USER_TRACE and IGNORE_ERRORS then
	    begin
	      dbms_output.put_line('[TRUNCATED]');
            exception
	      when APP_EXCEPTION then
		  null;
	    end;
	  else
	    raise;
	  end if;
      end;
    end if;
    if TO_USER_TRACE then
	dbms_system.ksdwrt(1,tmp);
    end if;
  end;
 --
  procedure put(txt varchar2) is
  begin
    tmp:=txt||chr(0);
    tmp:=txt;
    if TO_DBMS_OUTPUT then
      begin
	dbms_output.put(txt);
      exception
	when APP_EXCEPTION then
	  -- If DBMS_OUTPUT is full then carry on if we are writing to
	  -- the trace file and ignoring errors, otherwise error now
	  if TO_USER_TRACE and IGNORE_ERRORS then
	    begin
	      dbms_output.put('[TRUNCATED]');
            exception
	      when APP_EXCEPTION then
		  null;
	    end;
	  else
	    raise;
	  end if;
      end;
    end if;
    if TO_USER_TRACE then
	dbms_system.ksdwrt(1,tmp);
    end if;
  end;
 --
  procedure new_line is
  begin
    if TO_DBMS_OUTPUT then
      begin
	dbms_output.new_line;
      exception
	when APP_EXCEPTION then
	  if TO_USER_TRACE and IGNORE_ERRORS then
	    null;
	  else
	    raise;
	  end if;
      end;
    end if;
    if TO_USER_TRACE then
	dbms_system.ksdwrt(1,' ');
    end if;
  end;
 --
  procedure wrap(txt varchar2, linelen number default 78) is
    p   integer:=1;
    len integer;
    pos integer;
    chunk varchar2(2000);
    xchunk varchar2(2000);
    llen number:=linelen;
  BEGIN
    if (llen>2000) then
	llen:=2000;
    end if;
    if (llen<=1) then
	llen:=78;
    end if;
    len:=length(txt);
    while (p<=len) loop
      chunk:=substr(txt,p,llen);
      pos:=instr(chunk,chr(10),-1);
      if pos>0 then
       -- We have a CR in the text - use it
       put_line(substr(chunk,1,pos-1));
       p:=p+pos;
      else 
       -- No CR in the text so we will look for a split character
       xchunk:=translate(chunk,' ,()=',',,,,,');
       pos:=instr(xchunk,',',-1);
       if pos>0 and len>llen then
        put_line(substr(chunk,1,pos));
	p:=p+pos;
       else
        put(chunk);
	p:=p+llen;
       end if;
      end if;
    end loop;
    new_line;
  END;
 --
  procedure rule_off is
  begin
    put_line('=========================================================');
  end;
 --
begin
  dbms_output.enable(100000);
end hout;
/
REM ======================================================================
