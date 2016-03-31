REM  $Id: purge_wf.sql,v 120.1 2013/04/16 20:20:44 globsupt Exp globsupt $ 
REM +=======================================================================+
REM |    Copyright (c) 2013 Oracle Corporation, Redwood Shores, CA, USA     |
REM |                         All rights reserved.                          |
REM +=======================================================================+
REM | FILENAME                                                              |
REM |   purge_wf.sql                                                        |
REM |                                                                       |
REM | DESCRIPTION                                                           |
REM |   Script to automate purging of various types of obsolete workflow    |
REM |   data for Purchasing.                                                |
REM |                                                                       |
REM | HISTORY                                                               |
REM |  04-APR-2013 ALUMPE   Created.                                        |
REM +=======================================================================+

SET SERVEROUTPUT ON SIZE 1000000
SET VERIFY OFF
SET DEFINE "&"

PROMPT Enter the document type (PO, REQ, or BOTH)
PROMPT
ACCEPT doctype PROMPT 'Enter the document type [BOTH]: '

PROMPT
PROMPT Enter the number of days old the WF process must be to be considered
PROMPT
ACCEPT num_days NUMBER PROMPT 'Enter the number of days [0]: '

PROMPT
PROMPT Enter Y or N to indicate if the purge process should be submitted
PROMPT
ACCEPT sub_purge PROMPT 'Submit purge concurrent process [N]: '

PROMPT
PROMPT If submitting the purge enter a valid applications user name
PROMPT otherwise just press <enter>
PROMPT
ACCEPT username PROMPT 'Enter applications user name: '

SET FEEDBACK OFF
DECLARE
  CURSOR get_resp(uname IN VARCHAR2) IS
  SELECT urg.responsibility_Id,
       r.responsibility_name
  FROM fnd_user u,
       fnd_user_resp_groups urg,
       fnd_responsibility_vl r
  WHERE u.user_name = upper(uname)
  AND   urg.user_id = u.user_id
  AND   r.responsibility_id = urg.responsibility_id
  AND   urg.responsibility_application_id = 201;
BEGIN
  IF upper('&sub_purge') = 'Y' THEN
    dbms_output.put_line(chr(10)||'Valid Purchasing responsibilities for '
      ||'&username:'||chr(10));
    FOR rec IN get_resp('&username') LOOP
      dbms_output.put_line('Responsibility ID: '||to_char(rec.responsibility_id)
        ||'  Name: '||rec.responsibility_name);
    END LOOP;
  END IF;
EXCEPTION WHEN OTHERS THEN
  dbms_output.put_line('Error getting responsibility list: '|| sqlerrm);
END;
/
SET FEEDBACK ON

PROMPT
PROMPT If submitting the purge enter a valid purchasing responsibility id
PROMPT for the selected user.  If none are listed, press Ctrl-C to exit
PROMPT and re-enter a valid purchasing applications user. If not submitting
PROMPT the concurrent process simply press <enter>
PROMPT
ACCEPT resp NUMBER PROMPT 'Enter Purchasing responsibility ID: '

DECLARE

--   exec WF_ENGINE.AbortProcess(item_type, ias.item_key);
--   Then run the Purge Obsolete Runtime Workflow Program for
--   PO Approval item type with Age = 0.

  doctype   VARCHAR2(5) := upper('&doctype');   -- PO or REQ or BOTH
  start_dt  DATE := trunc(sysdate) - &num_days;
  sub_purge VARCHAR2(1) := upper('&sub_purge'); -- Y or N
  username  VARCHAR2(100) := upper('&username');    -- Valid apps user
  respid    NUMBER := &resp;                    -- Purchasing resp
  userid    NUMBER;
  numvar    NUMBER;
  msg_out   VARCHAR2(500);
  counter   NUMBER := 0;

  param_error EXCEPTION;

  CURSOR po1 IS
  SELECT DISTINCT
         ias.item_type,
         ias.item_key
  FROM wf_items i,
       wf_item_activity_statuses ias
  WHERE i.parent_item_type = 'POAPPRV'
  AND   i.item_key = ias.item_key
  AND   i.item_type = ias.item_type
  AND   i.begin_date <= start_dt
  AND   ias.activity_status <> 'COMPLETE'
  AND   parent_item_key IN (
          SELECT i1.item_key
          FROM wf_items i1,
               po_headers_all h
          WHERE i1.item_key = h.wf_item_key
          AND   i1.item_type = 'POAPPRV'
          AND   h.authorization_status NOT IN ('IN PROCESS','PRE-APPROVED')
          UNION
          SELECT i1.item_key
          FROM wf_items i1,
               po_releases_all r
          WHERE i1.item_key = r.wf_item_key
          AND   i1.item_type = 'POAPPRV'
          AND   r.authorization_status NOT IN ('IN PROCESS','PRE-APPROVED'))
  AND   ias.end_date is null;


  CURSOR po2 IS
  SELECT DISTINCT
        ias.item_type,
        ias.item_key
  FROM wf_items i,
       wf_item_activity_statuses ias
  WHERE i.parent_item_type = 'POAPPRV'
  AND   i.item_key = ias.item_key
  AND   i.item_type = ias.item_type
  AND   i.begin_date <= start_dt
  AND   ias.activity_status <> 'COMPLETE'
  AND   NOT EXISTS (
          SELECT 1 FROM po_headers_all h
          WHERE h.wf_item_key = i.parent_item_key
          UNION
          SELECT 1 FROM po_releases_all r
          WHERE r.wf_item_key = i.parent_item_key)
  AND   ias.end_date is null;


  CURSOR po3 IS
  SELECT DISTINCT
         ias.item_type,
         ias.item_key
  FROM wf_item_activity_statuses ias,
       wf_items i
  WHERE ias.item_type = 'POAPPRV'
  AND   ias.activity_status <> 'COMPLETE'
  AND   i.item_type = ias.item_type
  AND   i.item_key = ias.item_key
  AND   i.begin_date <= start_dt
  AND   i.end_date is null
  AND   NOT EXISTS (
          SELECT 1 FROM po_headers_all h
          WHERE  h.wf_item_key = ias.item_key
          UNION
          SELECT 1 from po_releases_all r
          WHERE  r.wf_item_key = ias.item_key);


  CURSOR po4 IS
  SELECT DISTINCT
        ias.item_type,
        ias.item_key
  FROM wf_item_activity_statuses ias,
       wf_items i
  WHERE ias.item_type = 'POAPPRV'
  AND   ias.activity_status <> 'COMPLETE'
  AND   EXISTS (
          SELECT 1 FROM po_headers_all h
          WHERE h.wf_item_key = ias.item_key
          AND   h.authorization_status NOT IN ('IN PROCESS','PRE-APPROVED')
          UNION
          SELECT 1 FROM po_releases_all r
          WHERE r.wf_item_key = ias.item_key
          AND   r.authorization_status NOT IN ('IN PROCESS','PRE-APPROVED'))
  AND   i.item_type = ias.item_type
  AND   i.item_key = ias.item_key
  AND   i.begin_date <= start_dt
  AND   i.end_date is null;


  CURSOR po_ag IS
  SELECT i.item_type,
         i.item_key
  FROM wf_items i
  WHERE i.end_date is null
  START WITH i.item_type = 'POWFPOAG'
  AND        i.begin_date <= start_dt
  CONNECT BY PRIOR i.item_type = i.parent_item_type
  AND        PRIOR i.item_key = i.parent_item_key
  ORDER BY i.begin_date;


  CURSOR req1 IS
  SELECT DISTINCT
         ias.item_type,
         ias.item_key
  FROM wf_items i,
       wf_item_activity_statuses ias
  WHERE i.parent_item_type = 'REQAPPRV'
  AND   i.item_key = ias.item_key
  AND   i.item_type = ias.item_type
  AND   i.begin_date <= start_dt
  AND   ias.activity_status <> 'COMPLETE'
  AND   parent_item_key IN (
          SELECT i1.item_key
          FROM wf_items i1,
               po_requisition_headers_all r
          WHERE i1.item_key = r.wf_item_key(+)
  AND   i1.item_type = 'REQAPPRV'
  AND   r.authorization_status NOT IN ('IN PROCESS','PRE-APPROVED'))
  AND   ias.end_date is null;


  CURSOR req2 IS
  SELECT DISTINCT
         ias.item_type,
         ias.item_key
  FROM wf_items i,
       wf_item_activity_statuses ias
  WHERE i.parent_item_type = 'REQAPPRV'
  AND   i.item_key = ias.item_key
  AND   i.item_type = ias.item_type
  AND   i.begin_date <= start_dt
  AND   ias.activity_status <> 'COMPLETE'
  AND   parent_item_key IN (
          SELECT i1.item_key
          FROM wf_items i1,
               po_requisition_headers_all r
          WHERE i1.item_key = r.wf_item_key(+)
          AND   i1.item_type = 'REQAPPRV'
          AND   r.wf_item_key is null
          AND   r.wf_item_type is null)
  AND   ias.end_date is null;


  CURSOR req3 IS
  SELECT DISTINCT
         ias.item_type,
         ias.item_key
  FROM wf_item_activity_statuses ias,
       wf_items i,
       po_requisition_headers_all r
  WHERE ias.item_key = r.wf_item_key(+)
  AND   ias.item_type = 'REQAPPRV'
  AND   ias.activity_status <> 'COMPLETE'
  AND   r.wf_item_key is null
  AND   r.wf_item_type is null
  AND   i.item_type = ias.item_type
  AND   i.item_key = ias.item_key
  AND   i.begin_date <= start_dt
  AND   i.end_date is null;


  CURSOR req4 IS
  SELECT DISTINCT
         ias.item_type,
         ias.item_key
  FROM wf_item_activity_statuses ias,
       wf_items i,
       po_requisition_headers_all r
  WHERE ias.item_key = r.wf_item_key
  AND   ias.item_type = 'REQAPPRV'
  AND   ias.activity_status <> 'COMPLETE'
  AND   r.authorization_status NOT IN ('IN PROCESS','PRE-APPROVED')
  AND   i.item_type = ias.item_type
  AND   i.item_key = ias.item_key
  AND   i.begin_date <= start_dt
  AND   i.end_date is null;


  CURSOR req_ag IS
  SELECT i.item_type,
         i.item_key
  FROM wf_items i
  WHERE i.end_date is null
  START WITH i.item_type = 'POWFRQAG'
  AND        i.begin_date <= start_dt
  CONNECT BY PRIOR i.item_type = i.parent_item_type
  AND        PRIOR i.item_key = i.parent_item_key
  ORDER BY i.begin_date;

BEGIN

  IF doctype is null THEN
    doctype := 'BOTH';
  END IF;
  IF doctype NOT IN ('PO', 'REQ', 'BOTH') THEN
    dbms_output.put_line('Invalid document type entered. '||
      'The value must be one of PO, REQ, or BOTH');
    raise param_error;
  END IF;

  IF sub_purge is null THEN
    sub_purge := 'N';
  END IF;
  IF sub_purge NOT IN ('Y','N') THEN
    dbms_output.put_line('Invalid value entered for submit purge. '||
      'The value must be one of Y or N.');
    raise param_error;
  END IF;
  IF sub_purge = 'Y' THEN
    BEGIN
      SELECT user_id INTO userid
      FROM fnd_user 
      WHERE user_name = username;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      dbms_output.put_line(username||' is not a valid applications user.');
      raise param_error;
    END;
    BEGIN
      SELECT r.responsibility_id INTO numvar
      FROM fnd_user_resp_groups urg,
           fnd_responsibility_vl r
      WHERE urg.user_id = userid
      AND   r.responsibility_id = urg.responsibility_id
      AND   r.responsibility_id = respid
      AND   urg.responsibility_application_id = 201;
    EXCEPTION WHEN NO_DATA_FOUND THEN
      dbms_output.put_line(to_char(respid)||' is not a valid '||
        'Purchasing responsibility id for user '||username);
      raise param_error;
    END;
    dbms_output.put_line('Initializing APPS context');
    fnd_global.apps_initialize(userid, respid, 201);
  END IF;

  IF doctype = 'PO' OR doctype = 'BOTH' THEN

    dbms_output.put_line('Processing incomplete WF activities for child processes of approved PO''s');
    counter := 0;
    FOR rec IN po1 LOOP
      BEGIN
        wf_engine.abortprocess(rec.item_type, rec.item_key);
        counter := counter + 1;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));
    

    dbms_output.put_line('Processing incomplete activities for child processes not associated to a PO');
    counter := 0;
    FOR rec IN po2 LOOP
      BEGIN
        wf_engine.abortprocess(rec.item_type, rec.item_key);
        counter := counter + 1;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

    dbms_output.put_line('Processing incomplete activities for workflows not associated to a PO');
    counter := 0;
    FOR rec IN po3 LOOP
      BEGIN
        wf_engine.abortprocess(rec.item_type, rec.item_key);
        counter := counter + 1;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

    dbms_output.put_line('Processing incomplete activities for approved PO''s');
    counter := 0;
    FOR rec IN po4 LOOP
      BEGIN
        wf_engine.abortprocess(rec.item_type, rec.item_key);
        counter := counter + 1;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

    dbms_output.put_line('Processing PO Account Generator Workflows');
    counter := 0;
    FOR rec IN po_ag LOOP
      BEGIN
        UPDATE wf_items
        SET end_date = sysdate
        WHERE item_type = rec.item_type
        AND   item_key = rec.item_key;
        counter := counter + sql%rowcount;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

  END IF;

  IF doctype = 'REQ' OR doctype = 'BOTH' THEN
    
    dbms_output.put_line('Processing incomplete WF activities for child processes of approved Requisitions');
    counter := 0;
    FOR rec IN req1 LOOP
      BEGIN
        wf_engine.abortprocess(rec.item_type, rec.item_key);
        counter := counter + 1;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

    dbms_output.put_line('Processing incomplete activities for child processes not associated to a Requisition');
    counter := 0;
    FOR rec IN req2 LOOP
      BEGIN
        wf_engine.abortprocess(rec.item_type, rec.item_key);
        counter := counter + 1;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

    dbms_output.put_line('Processing incomplete activities for workflows not associated to a Requistion');
    counter := 0;
    FOR rec IN req3 LOOP
      BEGIN
        wf_engine.abortprocess(rec.item_type, rec.item_key);
        counter := counter + 1;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

    dbms_output.put_line('Processing incomplete activities for approved Requisitions');
    counter := 0;
    FOR rec IN req4 LOOP
      BEGIN
        wf_engine.abortprocess(rec.item_type, rec.item_key);
        counter := counter + 1;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

    dbms_output.put_line('Processing Requisition Account Generator Workflows');
    counter := 0;
    FOR rec IN req_ag LOOP
      BEGIN
        UPDATE wf_items
        SET end_date = sysdate
        WHERE item_type = rec.item_type
        AND   item_key = rec.item_key;
        counter := counter + sql%rowcount;
        commit;
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error on '||rec.item_type||' Key: '||
          rec.item_key||': '||sqlerrm);
        rollback;
      END;
    END LOOP;
    dbms_output.put_line(to_char(counter)||' records successfully processed'||chr(10));

  END IF;
  
  IF sub_purge = 'Y' THEN
    dbms_output.put_line('Submitting Purge concurrent processes');
    IF doctype IN ('PO','BOTH') THEN
      BEGIN
        dbms_output.put_line('Purging item type POAPPRV');
        numvar := fnd_request.submit_request(
          'FND', 'FNDWFPR', 'Purge Obsolete Workflow Runtime Data',
          NULL, FALSE, 'POAPPRV', NULL, '0', 'TEMP', 'N',
          '500', 'N', chr(0));   
        fnd_message.retrieve(msg_out);
        dbms_output.put_line(msg_out);
        commit;
        dbms_output.put_line('Request ID: '||to_char(numvar));
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error submitting FNDWFPR for POAPPRV: '
          ||sqlerrm);
        raise;
      END;
      BEGIN
        dbms_output.put_line('Purging item type POWFRQAG');
        numvar := fnd_request.submit_request(
          'FND', 'FNDWFPR', 'Purge Obsolete Workflow Runtime Data',
          NULL, FALSE, 'POWFRQAG', NULL, '0', 'TEMP', 'N',
          '500', 'N', chr(0));   
        fnd_message.retrieve(msg_out);
        dbms_output.put_line(msg_out);
        commit;
        dbms_output.put_line('Request ID: '||to_char(numvar));
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error submitting FNDWFPR for POWFRQAG: '
          ||sqlerrm);
        raise;
      END;
      BEGIN
        dbms_output.put_line('Purging item type POERROR');
        numvar := fnd_request.submit_request(
          'FND', 'FNDWFPR', 'Purge Obsolete Workflow Runtime Data',
          NULL, FALSE, 'POERROR', NULL, '0', 'TEMP', 'N',
          '500', 'N', chr(0));   
        fnd_message.retrieve(msg_out);
        dbms_output.put_line(msg_out);
        commit;
        dbms_output.put_line('Request ID: '||to_char(numvar));
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error submitting FNDWFPR for POERROR: '
          ||sqlerrm);
        raise;
      END;
      BEGIN
        dbms_output.put_line('Purging item type WFERROR');
        numvar := fnd_request.submit_request(
          'FND', 'FNDWFPR', 'Purge Obsolete Workflow Runtime Data',
          NULL, FALSE, 'WFERROR', NULL, '0', 'TEMP', 'N',
          '500', 'N', chr(0));   
        fnd_message.retrieve(msg_out);
        dbms_output.put_line(msg_out);
        commit;
        dbms_output.put_line('Request ID: '||to_char(numvar));
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error submitting FNDWFPR for WFERROR: '
          ||sqlerrm);
        raise;
      END;
      BEGIN
        dbms_output.put_line('Purging item type POXML');
        numvar := fnd_request.submit_request(
          'FND', 'FNDWFPR', 'Purge Obsolete Workflow Runtime Data',
          NULL, FALSE, 'POXML', NULL, '0', 'TEMP', 'N',
          '500', 'N', chr(0));   
        fnd_message.retrieve(msg_out);
        dbms_output.put_line(msg_out);
        commit;
        dbms_output.put_line('Request ID: '||to_char(numvar));
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error submitting FNDWFPR for POXML: '
          ||sqlerrm);
        raise;
      END;
    END IF;
    IF doctype IN ('REQ','BOTH') THEN
      BEGIN
        dbms_output.put_line('Purging item type REQAPPRV');
        numvar := fnd_request.submit_request(
          'FND', 'FNDWFPR', 'Purge Obsolete Workflow Runtime Data',
          NULL, FALSE, 'REQAPPRV', NULL, '0', 'TEMP', 'N',
          '500', 'N', chr(0));   
        fnd_message.retrieve(msg_out);
        dbms_output.put_line(msg_out);
        commit;
       dbms_output.put_line('Request ID: '||to_char(numvar));
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error submitting FNDWFPR for REQAPPRV: '
          ||sqlerrm);
        raise;
      END;
      BEGIN
        dbms_output.put_line('Purging item type POWFRQAG');
        numvar := fnd_request.submit_request(
          'FND', 'FNDWFPR', 'Purge Obsolete Workflow Runtime Data',
          NULL, FALSE, 'POWFRQAG', NULL, '0', 'TEMP', 'N',
          '500', 'N', chr(0));   
        fnd_message.retrieve(msg_out);
        dbms_output.put_line(msg_out);
        commit;
        dbms_output.put_line('Request ID: '||to_char(numvar));
      EXCEPTION WHEN OTHERS THEN
        dbms_output.put_line('Error submitting FNDWFPR for POWFRQAG: '
          ||sqlerrm);
        raise;
      END;
      IF doctype = 'REQ' THEN
        BEGIN
          dbms_output.put_line('Purging item type WFERROR');
          numvar := fnd_request.submit_request(
            'FND', 'FNDWFPR', 'Purge Obsolete Workflow Runtime Data',
            NULL, FALSE, 'WFERROR', NULL, '0', 'TEMP', 'N',
            '500', 'N', chr(0));   
          fnd_message.retrieve(msg_out);
          dbms_output.put_line(msg_out);
          commit;
         dbms_output.put_line('Request ID: '||to_char(numvar));
        EXCEPTION WHEN OTHERS THEN
          dbms_output.put_line('Error submitting FNDWFPR for WFERROR: '
            ||sqlerrm);
          raise;
        END;
      END IF;
    END IF;
  END IF;
EXCEPTION WHEN OTHERS THEN
  dbms_output.put_line('Error: '||sqlerrm);
  rollback;
END;
/
