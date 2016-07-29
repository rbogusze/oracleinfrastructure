----------------------------------------------------------------------------------------
--
--      analyzereq.sql
--      Analyze a concurrent request
--
--      USAGE: sqlplus apps_user/apps_passwd @analyzereq request_id
--      EX:    sqlplus apps/apps @analyzereq 304504
--
--
--      $Id: analyzereq.sql,v 1.2 2000/04/03 04:18:04 pferguso Exp $
--
--      $Log: analyzereq.sql,v $
--      Revision 1.2  2000/04/03 04:18:04  pferguso
--      added print_mgrs, more request info
--      
--      Revision 1.1.1.1  2000/02/23 22:00:36  pferguso
--      initial import into CVS
--      
--      Revision 1.3  1999-12-29 13:46:44-05  pferguso
--      added responsibility info, logfile names
--
--      Revision 1.2  1999-12-29 13:13:58-05  pferguso
--      first usable version
--
--      Revision 1.1  1999-10-19 18:04:23-04  pferguso
--      Initial revision
--
--
--
----------------------------------------------------------------------------------------


set serveroutput on
set feedback off
set verify off
set heading off
set timing off

variable        help_text  varchar2(2000);

prompt

DECLARE

req_id          number(15) := &1;



FUNCTION  get_status(p_status_code varchar2) return varchar2 AS

c_status        fnd_lookups.meaning%TYPE;

BEGIN
        SELECT nvl(meaning, 'UNKNOWN') 
           INTO c_status
           FROM fnd_lookups
           WHERE LOOKUP_TYPE = 'CP_STATUS_CODE'
           AND LOOKUP_CODE = p_status_code;

        return rtrim(c_status);

END get_status;



FUNCTION  get_phase(p_phase_code varchar2) return varchar2 AS

c_phase         fnd_lookups.meaning%TYPE;

BEGIN
        SELECT nvl(meaning, 'UNKNOWN') 
           INTO c_phase
           FROM fnd_lookups
           WHERE LOOKUP_TYPE = 'CP_PHASE_CODE'
           AND LOOKUP_CODE = p_phase_code;

        return rtrim(c_phase);

END get_phase;



PROCEDURE manager_check  (req_id        in  number,
                          cd_id         in  number,
                          mgr_defined   out boolean,
                          mgr_active    out boolean,
                          mgr_workshift out boolean,
                          mgr_running   out boolean,
                          run_alone     out boolean) is

    cursor mgr_cursor (rid number) is
      select running_processes, max_processes,
             decode(control_code,
                    'T','N',       -- Abort
                    'X','N',       -- Aborted
                    'D','N',       -- Deactivate
                    'E','N',       -- Deactivated
                        'Y') active
        from fnd_concurrent_worker_requests
        where request_id = rid
          and not((queue_application_id = 0)
                  and (concurrent_queue_id in (1,4)));

    run_alone_flag  varchar2(1);

  begin
    mgr_defined := FALSE;
    mgr_active := FALSE;
    mgr_workshift := FALSE;
    mgr_running := FALSE;

    for mgr_rec in mgr_cursor(req_id) loop
      mgr_defined := TRUE;
      if (mgr_rec.active = 'Y') then
        mgr_active := TRUE;
        if (mgr_rec.max_processes > 0) then
          mgr_workshift := TRUE;
        end if;
        if (mgr_rec.running_processes > 0) then
          mgr_running := TRUE;
        end if;
      end if;
    end loop;

    if (cd_id is null) then    
      run_alone_flag := 'N';   
    else
      select runalone_flag
        into run_alone_flag
        from fnd_conflicts_domain d
        where d.cd_id = manager_check.cd_id;
    end if;
    if (run_alone_flag = 'Y') then
      run_alone := TRUE;
    else
      run_alone := FALSE;
    end if;

  end manager_check;


PROCEDURE print_mgrs(p_req_id number) AS

CURSOR  c_mgrs(rid number) IS
        SELECT user_concurrent_queue_name name, fcwr.running_processes active,
        decode(fcwr.control_code,        'A', fl.meaning,
                                         'D', fl.meaning,
                                         'E', fl.meaning, 
                                         'N', fl.meaning,
                                         'R', fl.meaning,
                                         'T', fl.meaning,
                                         'U', fl.meaning,
                                         'V', fl.meaning,
                                         'X', fl.meaning,
                                         NULL, 'Running',
                                         '** Unknown Status **') status
        FROM fnd_concurrent_queues_vl fcqv, fnd_concurrent_worker_requests fcwr, fnd_lookups fl
        WHERE fcwr.request_id = rid
        AND fcwr.concurrent_queue_id = fcqv.concurrent_queue_id
        AND fcwr.concurrent_queue_id not in (1, 4)
        AND fl.lookup_code (+) = fcwr.control_code
        AND fl.lookup_type (+) = 'CP_CONTROL_CODE';

BEGIN

        for mgr_rec in c_mgrs(p_req_id) loop
            DBMS_OUTPUT.PUT_LINE('- ' || mgr_rec.name || ' | Status: ' || mgr_rec.status
|| ' (' || mgr_rec.active || ' active processes)');
        end loop;

END print_mgrs;


PROCEDURE analyze_request(p_req_id number) AS

reqinfo         fnd_concurrent_requests%ROWTYPE;
proginfo        fnd_concurrent_programs_vl%ROWTYPE;

c_status        fnd_lookups.meaning%TYPE;
m_buf           fnd_lookups.meaning%TYPE;
conc_prog_name  fnd_concurrent_programs.concurrent_program_name%TYPE;
exe_method_code fnd_concurrent_programs_vl.execution_method_code%TYPE;
conc_app_name   fnd_application_vl.application_name%TYPE;
tmp_id          number(15);
tmp_status      fnd_concurrent_requests.status_code%TYPE;
tmp_date        date;
conc_app_id     fnd_concurrent_requests.program_application_id%TYPE;
conc_id         fnd_concurrent_requests.concurrent_program_id%TYPE;
conc_cd_id      fnd_concurrent_requests.cd_id%TYPE;
v_enabled_flag  fnd_concurrent_programs.enabled_flag%TYPE;
conflict_domain fnd_conflicts_domain.user_cd_name%TYPE;
parent_id       number(15);
resp_name       varchar2(100);
rclass_name     fnd_concurrent_request_class.request_class_name%TYPE;
exe_file_name   fnd_executables.execution_file_name%TYPE;

c_user          fnd_user.user_name%TYPE;
last_user       fnd_user.user_name%TYPE;

fcd_phase       varchar2(48);
fcd_status      varchar2(48);

traid           fnd_concurrent_requests.program_application_id%TYPE;
trcpid          fnd_concurrent_requests.concurrent_program_id%TYPE;

icount          number;
ireqid          fnd_concurrent_requests.request_id%TYPE;
pcode           fnd_concurrent_requests.phase_code%TYPE;
scode           fnd_concurrent_requests.status_code%TYPE;

live_child      boolean;
mgr_defined     boolean;
mgr_active      boolean;
mgr_workshift   boolean;
mgr_running     boolean;
run_alone       boolean;
reqlimit        boolean := false;

mgrname         fnd_concurrent_queues_vl.user_concurrent_queue_name%TYPE;
filename        varchar2(255);

qcf             fnd_concurrent_programs.queue_control_flag%TYPE;

apps_version    varchar2(3);

sep             varchar2(200) := '------------------------------------------------------';

REQ_NOTFOUND    exception;


CURSOR  c_wait IS
        SELECT request_id, phase_code, status_code
        FROM fnd_concurrent_requests
        WHERE parent_request_id = p_req_id;

CURSOR  c_inc IS
        SELECT to_run_application_id, to_run_concurrent_program_id
        FROM fnd_concurrent_program_serial
        WHERE running_application_id = conc_app_id
        AND running_concurrent_program_id = conc_id;

CURSOR  c_ireqs IS
        SELECT request_id, phase_code, status_code
        FROM   fnd_concurrent_requests
        WHERE  phase_code = 'R'
        AND    program_application_id = traid
        AND    concurrent_program_id = trcpid
        AND    cd_id = conc_cd_id;

CURSOR c_userreqs(uid number, s date) IS
       SELECT request_id, to_char(requested_start_date, 'DD-MON-RR HH24:MI:SS') start_date,
              phase_code, status_code
       FROM fnd_concurrent_requests
       WHERE phase_code IN ('R', 'P')
       AND requested_by = uid
       AND requested_start_date < s
       AND hold_flag = 'N';

BEGIN

        BEGIN
            SELECT *
            INTO   reqinfo
            FROM   fnd_concurrent_requests
            WHERE  request_id = p_req_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                raise REQ_NOTFOUND;
        END;
        
        DBMS_OUTPUT.PUT_LINE('Analyzing request '||req_id||':');
        DBMS_OUTPUT.PUT_LINE(sep);


-- Program information
        DBMS_OUTPUT.PUT_LINE('Program information:');

        SELECT fvl.*
        INTO proginfo
        FROM fnd_concurrent_programs_vl fvl, fnd_concurrent_requests fcr
        WHERE fcr.request_id = p_req_id
        AND fcr.concurrent_program_id = fvl.concurrent_program_id
        AND fcr.program_application_id = fvl.application_id;

        DBMS_OUTPUT.PUT_LINE('Program: '|| proginfo.user_concurrent_program_name
|| '  (' || proginfo.concurrent_program_name || ')');

        SELECT nvl(application_name, '-- UNKNOWN APPLICATION --')
        INTO conc_app_name
        FROM fnd_application_vl fvl, fnd_concurrent_requests fcr
        WHERE fcr.request_id = p_req_id
        AND fcr.program_application_id = fvl.application_id;

        DBMS_OUTPUT.PUT_LINE('Application: '||conc_app_name);

        SELECT nvl(meaning, 'UNKNOWN')
        INTO  m_buf 
        FROM fnd_lookups
        WHERE lookup_type = 'CP_EXECUTION_METHOD_CODE'
        AND lookup_code = proginfo.execution_method_code;

        SELECT nvl(execution_file_name, 'NONE')
        INTO exe_file_name
        FROM fnd_executables
        WHERE application_id = proginfo.executable_application_id
        AND executable_id = proginfo.executable_id;

        DBMS_OUTPUT.PUT_LINE('Executable type: ' || m_buf || '  (' || proginfo.execution_method_code || ')');
        DBMS_OUTPUT.PUT_LINE('Executable file name or procedure: ' || exe_file_name);
        DBMS_OUTPUT.PUT_LINE('Run alone flag: ' || proginfo.run_alone_flag);
        DBMS_OUTPUT.PUT_LINE('SRS flag: ' || proginfo.srs_flag);
        DBMS_OUTPUT.PUT_LINE('NLS compliant: ' || proginfo.nls_compliant);
        DBMS_OUTPUT.PUT_LINE('Output file type: ' || proginfo.output_file_type);

        if proginfo.concurrent_class_id is not null then
                select request_class_name
                into rclass_name
                from fnd_concurrent_request_class
                where application_id = proginfo.class_application_id
                and request_class_id = proginfo.concurrent_class_id;

                DBMS_OUTPUT.PUT_LINE('Request type: ' || rclass_name);
        end if;

        if proginfo.execution_options is not null then
                DBMS_OUTPUT.PUT_LINE('Execution options: ' || proginfo.execution_options);
        end if;

        if proginfo.enable_trace = 'Y' then
                DBMS_OUTPUT.PUT_LINE('SQL Trace has been enabled for this program.');
        end if;
        
        DBMS_OUTPUT.PUT_LINE(sep);
        DBMS_OUTPUT.PUT_LINE('
                             ');
        DBMS_OUTPUT.PUT_LINE(sep);

-- Submission information
        DBMS_OUTPUT.PUT_LINE('Submission information:');

        begin
                SELECT user_name into c_user from fnd_user
                where user_id = reqinfo.requested_by;
        exception
                when no_data_found then
                        c_user := '-- UNKNOWN USER --';
        end;

        begin
                SELECT user_name into last_user from fnd_user
                WHERE user_id = reqinfo.last_updated_by;
        exception
                when no_data_found then
                        last_user := '-- UNKNOWN USER --';
        end;

        DBMS_OUTPUT.PUT_LINE('It was submitted by user: '||c_user);
        SELECT responsibility_name
        INTO   resp_name
        FROM   fnd_responsibility_vl
        WHERE  responsibility_id = reqinfo.responsibility_id
        AND    application_id = reqinfo.responsibility_application_id;

        DBMS_OUTPUT.PUT_LINE('Using responsibility: ' || resp_name);
        DBMS_OUTPUT.PUT_LINE('It was submitted on: ' || to_char(reqinfo.request_date, 'DD-MON-RR HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('It was requested to start on: '||
                                 to_char(reqinfo.requested_start_date, 'DD-MON-RR HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('Parent request id: ' || reqinfo.parent_request_id);
        DBMS_OUTPUT.PUT_LINE('Language: ' || reqinfo.nls_language);
        DBMS_OUTPUT.PUT_LINE('Territory: ' || reqinfo.nls_territory);
        DBMS_OUTPUT.PUT_LINE('Priority: ' || to_char(reqinfo.priority));

        DBMS_OUTPUT.PUT_LINE('Arguments (' || reqinfo.number_of_arguments || '): ' || reqinfo.argument_text);

        c_status := get_status(reqinfo.status_code);

        DBMS_OUTPUT.PUT_LINE(sep);
        DBMS_OUTPUT.PUT_LINE('
                             ');
        DBMS_OUTPUT.PUT_LINE(sep);

-- Analysis
        DBMS_OUTPUT.PUT_LINE('Analysis:');


-- Completed Requests
-------------------------------------------------------------------------------------------------------------
        IF reqinfo.phase_code = 'C' THEN
           
              

              DBMS_OUTPUT.PUT_LINE('Request '||p_req_id||' has completed with status "'||c_status||'".');
              DBMS_OUTPUT.PUT_LINE('It began running on: '||
                                   nvl(to_char(reqinfo.actual_start_date, 'DD-MON-RR HH24:MI:SS'), 
                                                                          '-- NO START DATE --'));
              DBMS_OUTPUT.PUT_LINE('It completed on: '||
                                   nvl(to_char(reqinfo.actual_completion_date, 'DD-MON-RR HH24:MI:SS'), 
                                                                               '-- NO COMPLETION DATE --'));
              
              BEGIN
              SELECT user_concurrent_queue_name
              INTO   mgrname
              FROM   fnd_concurrent_queues_vl
              WHERE  concurrent_queue_id = reqinfo.controlling_manager;
              DBMS_OUTPUT.PUT_LINE('It was run by manager: ' || mgrname);
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                   DBMS_OUTPUT.PUT_LINE('It was run by an unknown manager.');
              END;
             
              SELECT nvl(reqinfo.logfile_name, '-- No logfile --')
              INTO   filename
              FROM   dual;
              DBMS_OUTPUT.PUT_LINE('Logfile: ' || filename);
              SELECT nvl(reqinfo.outfile_name, '-- No output file --')
              INTO   filename
              FROM   dual;
              DBMS_OUTPUT.PUT_LINE('Output file: ' || filename);

              DBMS_OUTPUT.PUT_LINE('It produced completion message: ');
              DBMS_OUTPUT.PUT_LINE(nvl(reqinfo.completion_text, '-- NO COMPLETION MESSAGE --'));
              
              


-- Running Requests
-------------------------------------------------------------------------------------------------------------
        ELSIF reqinfo.phase_code = 'R' THEN
              
                

                DBMS_OUTPUT.PUT_LINE('Request '||p_req_id||' is currently running with status "'||c_status||'".');
                DBMS_OUTPUT.PUT_LINE('It began running on: '||
                                         nvl(to_char(reqinfo.actual_start_date, 'DD-MON-RR HH24:MI:SS'), 
                                                                                '-- NO START DATE --'));
                BEGIN
                SELECT user_concurrent_queue_name
                INTO   mgrname
                FROM   fnd_concurrent_queues_vl
                WHERE  concurrent_queue_id = reqinfo.controlling_manager;
                DBMS_OUTPUT.PUT_LINE('It is being run by manager: ' || mgrname);
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     null;
                END;

                SELECT nvl(reqinfo.logfile_name, '-- No logfile --')
                INTO   filename
                FROM   dual;
                DBMS_OUTPUT.PUT_LINE('Logfile: ' || filename);
                SELECT nvl(reqinfo.outfile_name, '-- No output file --')
                INTO   filename
                FROM   dual;
                DBMS_OUTPUT.PUT_LINE('Output file: ' || filename);
                
                IF reqinfo.status_code = 'Z' THEN

                        -- Waiting request, See what it is waiting on
                        FOR child in c_wait LOOP

                                DBMS_OUTPUT.PUT_LINE('It is waiting on request '||
                                                         child.request_id||' phase = '||get_phase(child.phase_code)||
                                                         ' status = '||get_status(child.status_code));
                        END LOOP;
                
                ELSIF reqinfo.status_code = 'W' THEN
                        
                        -- Paused, check and see if it is a request set, and if its children are running
                        SELECT nvl(concurrent_program_name, 'UNKNOWN')
                        INTO conc_prog_name
                        FROM fnd_concurrent_programs
                        WHERE concurrent_program_id = reqinfo.concurrent_program_id;

                        
                        DBMS_OUTPUT.PUT_LINE('A Running/Paused request is waiting on one or more child requests to complete.');
                        IF conc_prog_name = 'FNDRSSTG' THEN
                                DBMS_OUTPUT.PUT_LINE('This program is a Request Set Stage.');
                        END IF;

                        IF instr(conc_prog_name, 'RSSUB') > 0  THEN
                                 DBMS_OUTPUT.PUT_LINE('This program is a Request Set parent program.');
                        END IF; 

                        live_child := FALSE;
                        FOR child in c_wait LOOP

                                DBMS_OUTPUT.PUT_LINE('It has a child request: '||
                                                         child.request_id||' (phase = '||get_phase(child.phase_code)||
                                                         ' - status = '||get_status(child.status_code)||')');
                                IF child.phase_code != 'C' THEN
                                        live_child := TRUE;
                                END IF;

                        END LOOP;
                        
                        IF live_child = FALSE THEN
                                DBMS_OUTPUT.PUT_LINE('This request has no child requests
that are still running. You may need to wake this request up manually.');
                        END IF;
                END IF;



-- Pending Requests
-------------------------------------------------------------------------------------------------------------
        ELSIF reqinfo.phase_code = 'P' THEN
              
              
              DBMS_OUTPUT.PUT_LINE('Request '||p_req_id||' is in phase "Pending" with status "'||c_status||'".');
              DBMS_OUTPUT.PUT_LINE('                           (phase_code = P)   (status_code = '||reqinfo.status_code||')');

              -- could be a queue control request
              SELECT queue_control_flag
              INTO   qcf
              FROM   fnd_concurrent_programs
              WHERE  concurrent_program_id = reqinfo.concurrent_program_id
              AND    application_id = reqinfo.program_application_id;
              
              IF qcf = 'Y' THEN
                DBMS_OUTPUT.PUT_LINE('This request is a queue control request');
                DBMS_OUTPUT.PUT_LINE('It will be run by the ICM on its next sleep cycle');
                GOTO diagnose;
              END IF;

              -- why is it pending?

              -- could be scheduled
              IF reqinfo.requested_start_date > sysdate or reqinfo.status_code = 'P' THEN
                 DBMS_OUTPUT.PUT_LINE('This is a scheduled request.');
                 DBMS_OUTPUT.PUT_LINE('It is currently scheduled to start running on '||
                                            to_char(reqinfo.requested_start_date, 'DD-MON-RR HH24:MI:SS'));
                 DBMS_OUTPUT.PUT_LINE('This should show on the form as Pending/Scheduled');
                 GOTO diagnose;
              END IF;

              -- could be on hold
              IF reqinfo.hold_flag = 'Y' THEN
                DBMS_OUTPUT.PUT_LINE('This request is currently on hold. It will not run until the hold is released.');
                DBMS_OUTPUT.PUT_LINE('It was placed on hold by: '||last_user||' on
'||to_char(reqinfo.last_update_date, 'DD-MON-RR HH24:MI:SS'));
                DBMS_OUTPUT.PUT_LINE('This should show on the form as Inactive/On Hold');
                GOTO diagnose;
              END IF;

              -- could be disabled
              IF proginfo.enabled_flag = 'N' THEN
                 DBMS_OUTPUT.PUT_LINE('This request is currently disabled.');
                 DBMS_OUTPUT.PUT_LINE('The concurrent_program '|| proginfo.user_concurrent_program_name
||' needs to be enabled for this request to run.');
                 DBMS_OUTPUT.PUT_LINE('This should show on the form as Inactive/Disabled');
                 GOTO diagnose;
              END IF;

              
              -- check queue_method_code
              -- unconstrained requests
              IF reqinfo.queue_method_code = 'I' THEN
                  DBMS_OUTPUT.PUT_LINE('This request is an unconstrained request. (queue_method_code = I)');
                  IF reqinfo.status_code = 'I' THEN
                      DBMS_OUTPUT.PUT_LINE('It is in a "Pending/Normal" status, ready
to be run by the next available manager.');
                  ELSIF reqinfo.status_code = 'Q' THEN
                      DBMS_OUTPUT.PUT_LINE('It has a status of "Standby" even though
it is unconstrained. It will not be run by any manager.');
                  ELSIF reqinfo.status_code IN ('A', 'Z') THEN
                      DBMS_OUTPUT.PUT_LINE('It is in a "Waiting" status. This usually
indicates a child request waiting for the parent to release it.');
                      SELECT nvl(parent_request_id, -1)
                      INTO   parent_id
                      FROM   fnd_conc_req_summary_v
                      WHERE  request_id = p_req_id;
                      IF parent_id = -1 THEN
                          DBMS_OUTPUT.PUT_LINE('** Unable to find a parent request for this request');
                      ELSE
                          DBMS_OUTPUT.PUT_LINE('It''s parent request id is: ' || to_char(parent_id));
                      END IF;
                  ELSE
                      DBMS_OUTPUT.PUT_LINE('Hmmm. A status of ' || reqinfo.status_code
|| '. I was not really expecting to see this status.');
                  END IF;

              -- constrained requests
              ELSIF reqinfo.queue_method_code = 'B' THEN
                  DBMS_OUTPUT.PUT_LINE('This request is a constrained request. (queue_method_code = B)');
                  IF reqinfo.status_code = 'I' THEN
                      DBMS_OUTPUT.PUT_LINE('The Conflict Resolution manager has released
this request, and it is in a "Pending/Normal" status.');
                      DBMS_OUTPUT.PUT_LINE('It is ready to be run by the next available manager.');
                  ELSIF reqinfo.status_code = 'Q' THEN
                      DBMS_OUTPUT.PUT_LINE('It is in a "Pending/Standby" status.
The Conflict Resolution manager will need to release it before it can be run.');
                  ELSIF reqinfo.status_code IN ('A', 'Z') THEN
                      DBMS_OUTPUT.PUT_LINE('It is in a "Waiting" status. This usually
indicates a child request waiting for the parent to release it.');
                      SELECT nvl(parent_request_id, -1)
                      INTO   parent_id
                      FROM   fnd_conc_req_summary_v
                      WHERE  request_id = p_req_id;
                      IF parent_id = -1 THEN
                          DBMS_OUTPUT.PUT_LINE('** Unable to find a parent request for this request');
                      ELSE
                          DBMS_OUTPUT.PUT_LINE('It''s parent request id is: ' || to_char(parent_id));
                      END IF;
                  ELSE
                      DBMS_OUTPUT.PUT_LINE('Hmmm. A status of ' || reqinfo.status_code
|| '. I was not really expecting to see this status.');
                  END IF;


                  -- incompatible programs
                  SELECT program_application_id, concurrent_program_id, cd_id
                  INTO   conc_app_id, conc_id, conc_cd_id
                  FROM   fnd_concurrent_requests
                  WHERE  request_id = p_req_id;

                  icount := 0;
                  FOR progs in c_inc LOOP

                        traid :=  progs.to_run_application_id;
                        trcpid := progs.to_run_concurrent_program_id;
        
                        OPEN c_ireqs;
                        LOOP

                                FETCH c_ireqs INTO ireqid, pcode, scode;
                                EXIT WHEN c_ireqs%NOTFOUND;
                        
                                DBMS_OUTPUT.PUT_LINE('Request '|| p_req_id ||' is
waiting, or will have to wait, on an incompatible request: '|| ireqid );
                                DBMS_OUTPUT.PUT_LINE('which has phase = '|| pcode ||' and status = '|| scode);
                                icount := icount + 1;
                
                
                        END LOOP;
                        CLOSE c_ireqs;

        
                  END LOOP;

                  IF icount = 0 THEN
                        DBMS_OUTPUT.PUT_LINE('No running incompatible requests were found for request '||p_req_id);
                  END IF;

                  -- could be a runalone itself
                  IF proginfo.run_alone_flag = 'Y' THEN
                      DBMS_OUTPUT.PUT_LINE('This request is constrained because it is a runalone request.');
                  END IF;

                  -- single threaded
                  IF reqinfo.single_thread_flag = 'Y' THEN
                      DBMS_OUTPUT.PUT_LINE('This request is constrained because the
profile option Concurrent: Sequential Requests is set.');
                      reqlimit := true;
                  END IF;

                  -- request limit
                  IF reqinfo.request_limit = 'Y' THEN
                      DBMS_OUTPUT.PUT_LINE('This request is constrained because the
profile option Concurrent: Active Request Limit is set.');
                      reqlimit := true;
                  END IF;

                  IF reqlimit = true THEN
                     DBMS_OUTPUT.PUT_LINE('This request may have to wait on these requests:');
                     FOR progs in c_userreqs(reqinfo.requested_by, reqinfo.requested_start_date) LOOP
                        DBMS_OUTPUT.PUT_LINE('Request id: ' || progs.request_id ||
' Requested start date: ' || progs.start_date);
                        DBMS_OUTPUT.PUT_LINE('     Phase: ' || get_phase(progs.phase_code)
|| '   Status: ' || get_status(progs.status_code));
                     END LOOP;
                  END IF;       

              -- error, invalid queue_method_code
              ELSE
                  DBMS_OUTPUT.PUT_LINE('** This request has an invalid queue_method_code of '||reqinfo.queue_method_code);
                  DBMS_OUTPUT.PUT_LINE('** This request will not be run. You may need to apply patch 739644.');
                  GOTO diagnose;
              END IF;


              DBMS_OUTPUT.PUT_LINE(sep);
              DBMS_OUTPUT.PUT_LINE('Checking managers available to run this request...');

              -- check the managers
              manager_check(p_req_id, reqinfo.cd_id, mgr_defined, mgr_active, mgr_workshift, mgr_running, run_alone);

              -- could be a runalone ahead of it
              IF run_alone = TRUE THEN
                    DBMS_OUTPUT.PUT_LINE('There is a runalone request running ahead of this request');
                    DBMS_OUTPUT.PUT_LINE('This should show on the form as Inactive/No Manager');
                    
                    select user_cd_name into conflict_domain from fnd_conflicts_domain
                    where cd_id = reqinfo.cd_id;

                    DBMS_OUTPUT.PUT_LINE('Conflict domain = '||conflict_domain);

                    -- see what is running
                    begin
                    select request_id, status_code, actual_start_date
                    into tmp_id, tmp_status, tmp_date
                    from fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
                    where fcp.run_alone_flag = 'Y'
                    and fcp.concurrent_program_id = fcr.concurrent_program_id
                    and fcr.phase_code = 'R'
                    and fcr.cd_id = reqinfo.cd_id;

                        DBMS_OUTPUT.PUT_LINE('This request is waiting for request '||tmp_id||
                                                 ', which is running with status '||get_status(tmp_status));
                        DBMS_OUTPUT.PUT_LINE('It has been running since: '||
                                         nvl(to_char(tmp_date, 'DD-MON-RR HH24:MI:SS'), '-- NO START DATE --'));
                    exception
                       when NO_DATA_FOUND then
                           DBMS_OUTPUT.PUT_LINE('** The runalone flag is set for conflict domain '||conflict_domain||
                                                        ', but there is no runalone request running');
                    end;
              
              ELSIF mgr_defined = FALSE THEN
                    DBMS_OUTPUT.PUT_LINE('There is no manager defined that can run this request');
                    DBMS_OUTPUT.PUT_LINE('This should show on the form as Inactive/No Manager');
                    DBMS_OUTPUT.PUT_LINE('Check the specialization rules for each
manager to make sure they are defined correctly.');
              ELSIF mgr_active = FALSE THEN
                    DBMS_OUTPUT.PUT_LINE('There are one or more managers defined
that can run this request, but none of them are currently active');
                    DBMS_OUTPUT.PUT_LINE('This should show on the form as Inactive/No Manager');
                    -- print out which managers can run it and their status
                    DBMS_OUTPUT.PUT_LINE('These managers are defined to run this request:');
                    print_mgrs(p_req_id);
              ELSIF mgr_workshift = FALSE THEN
                    DBMS_OUTPUT.PUT_LINE('Right now, there is no manager running
in an active workshift that can run this request');
                    DBMS_OUTPUT.PUT_LINE('This should show on the form as Inactive/No Manager');
                    -- display details about the workshifts
              ELSIF mgr_running = FALSE THEN
                    DBMS_OUTPUT.PUT_LINE('There is one or more managers available
to run this request, but none of them are running');
                    DBMS_OUTPUT.PUT_LINE('This should show on the form as Inactive/No Manager');
                    -- print out which managers can run it and their status
                    print_mgrs(p_req_id);
              ELSE
                    -- print out the managers available to run it
                    DBMS_OUTPUT.PUT_LINE('These managers are available to run this request:');
                    print_mgrs(p_req_id);
                    
              END IF;

             
        -- invalid phase code
        ELSE 
             DBMS_OUTPUT.PUT_LINE('Request '||p_req_id||' has an invalid phase_code of "'||reqinfo.phase_code||'"');

        END IF;

<<diagnose>>
        BEGIN
        FND_CONC.DIAGNOSE(p_req_id, fcd_phase, fcd_status, :help_text);
        EXCEPTION
            WHEN OTHERS THEN
                :help_text := 'The FND_CONC package has not been installed on this system.';
        END;
        
        DBMS_OUTPUT.PUT_LINE(sep);

EXCEPTION
        WHEN REQ_NOTFOUND THEN
            DBMS_OUTPUT.PUT_LINE('Request '||p_req_id||' not found.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error number ' || sqlcode || ' has occurred.');
            DBMS_OUTPUT.PUT_LINE('Cause: ' || sqlerrm);

END analyze_request;


BEGIN

analyze_request(req_id);



END;
/

prompt
prompt Additional information (from FND_CONC.DIAGNOSE):
print help_text;
set feedback on
set verify on
set heading on
set timing on