--
--------------------------------------------------------------------------
-- hcheck.sql          Version 3.50          Tue Mar 26 14:20:38 CEST 2013
--
-- Purpose:
--   To provide a single package which looks for common data dictionary
--   problems.
--     Note that this version has not been checked with locally managed
--     tablespaces and may give spurious output if these are in use.
--     This script is for use mainly under the guidance of Oracle Support.
--
-- Usage:
--   SQL> set serverout on size unlimited
--   SQL> exec hcheck.full [(parameters)]
--
--   Where parameters are
--        Verbose In Boolean - Verbose Output
--        RunAll  In Boolean - Run All procedures despite of Release
--        VerChk  In Number  - Check against 1st 'VerChk' release numbers
--
--   Output is to the hOut package to allow output to be redirected
--   as required
--
-- Depends on:
--   hOut
--
-- Notes:
--   Must be installed in SYS schema
--   This package is intended for use in Oracle releases 9i onwards
--   This package will NOT work in 8i or earlier.
--   In all cases any output reporting "problems" should be
--   parsed by an experienced Oracle Support analyst to confirm
--   if any action is required.
--
-- CAUTION
--   The sample program in this article is provided for educational
--   purposes only and is NOT supported by Oracle Support Services.
--   It has been tested internally, however, and works as documented.
--   We do not guarantee that it will work for you, so be sure to test
--   it in your environment before relying on it.
--
--------------------------------------------------------------------------
--

Create Or Replace Package hcheck Is
  Type sFuncNam Is Table Of Varchar2(32) Index By Binary_integer ;
  Type sFuncRel Is Table Of Varchar2(32) Index By Binary_integer ;
--
  sFn sFuncNam ;       /* Function Names                              */
  sFr sFuncRel ;       /* Version Control: Fixed Release per function */
--
-- Procedure Definitions
--
  Procedure SynLastDDLTim        
           (nF In Number Default 0, VerChk In Number Default 5,
            Verbose In Boolean Default FALSE) ; /*  1 */
  Procedure LobNotInObj          
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /*  2 */
  Procedure MissingOIDOnObjCol   
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /*  3 */
  Procedure SourceNotInObj       
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /*  4 */
  Procedure IndIndparMismatch    
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /*  5 */
  Procedure InvCorrAudit         
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /*  6 */
  Procedure OversizedFiles       
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /*  7 */
  Procedure TinyFiles            
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /*  8 */
  Procedure PoorDefaultStorage   
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /*  9 */
  Procedure PoorStorage          
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 10 */
  Procedure MissTabSubPart       
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 11 */
  Procedure PartSubPartMismatch  
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 12 */
  Procedure TabPartCountMismatch 
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 13 */
  Procedure OrphanedTabComPart
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 14 */
  Procedure ZeroTabSubPart
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 15 */
  Procedure MissingSum$
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 16 */
  Procedure MissingDir$
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 17 */
  Procedure DuplicateDataobj
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 18 */
  Procedure ObjSynMissing
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 19 */
  Procedure ObjSeqMissing
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 20 */
  Procedure OrphanedUndo
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 22 */
  Procedure OrphanedIndex
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 21 */
  Procedure OrphanedIndexPartition
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 23 */
  Procedure OrphanedIndexSubPartition
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 24 */
  Procedure OrphanedTable
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 25 */
  Procedure OrphanedTablePartition
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 26 */
  Procedure OrphanedTableSubPartition
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 27 */
  Procedure MissingPartCol
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 28 */
  Procedure OrphanedSeg$
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 29 */
  Procedure OrphanedIndPartObj#
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 30 */
  Procedure DuplicateBlockUse
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 31 */
  Procedure HighObjectIds
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 32 */
  Procedure PQsequence
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 33 */
  Procedure TruncatedCluster
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 34 */
  Procedure FetUet
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 35 */
  Procedure Uet0Check
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 36 */
  Procedure ExtentlessSeg
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 37 */
  Procedure SeglessUET
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 38 */
  Procedure BadInd$
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 39 */
  Procedure BadTab$
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 40 */
  Procedure BadIcolDepCnt
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 41 */
  Procedure WarnIcolDep
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 42 */
  Procedure OnlineRebuild$
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 43 */
  Procedure DropForceType
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 44 */
  Procedure TrgAfterUpgrade
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 45 */
  Procedure FailedInitJVMRun
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 46 */
  Procedure TypeReusedAfterDrop
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 47 */
  Procedure Idgen1$TTS
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 48 */
  Procedure DroppedFuncIdx
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 49 */
  Procedure BadOwner
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 50 */
  Procedure UpgCheckc0801070
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 51 */
  Procedure BadPublicObjects
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 52 */
  Procedure BadSegFreelist
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 53 */
  Procedure BadCol#
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 54 */
  Procedure BadDepends
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 55 */
  Procedure CheckDual
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 56 */
  Procedure ObjectNames
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 57 */
  Procedure BadCboHiLo
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 58 */
  Procedure ChkIotTs
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 59 */
  Procedure NoSegmentIndex
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 60 */
  Procedure BadNextObject
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 61 */
  Procedure OrphanIndopt
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 62 */
  Procedure UpgFlgBitTmp
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 63 */
  Procedure RenCharView
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 64 */
  Procedure Upg9iTab$
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 65 */
  Procedure Upg9iTsInd
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 66 */
  Procedure Upg10gInd$
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 67 */
  Procedure DroppedROTS
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 68 */
  Procedure ChrLenSmtcs
           (nF In Number Default 0, VerChk In Number Default 5, 
            Verbose In Boolean Default FALSE) ; /* 69 */
  Procedure FilBlkZero
           (nF In Number Default 0, VerChk In Number Default 5,
            Verbose In Boolean Default FALSE) ; /* 70 */
  Procedure DbmsSchemaCopy
           (nF In Number Default 0, VerChk In Number Default 5,
            Verbose In Boolean Default FALSE) ; /* 71 */
--
  bRun  Boolean      ;
  nFunc Number := 71 ; /* should be equal-to, not one-greater-than, the   */
                       /* highest expected number of procedures to be run */
--
-- Function  CatV2nCatV ( s In Varchar2, n in Number default 5 ) Return Number ;
-- Procedure ChecknCatVnFR ( nCatV In Number, nFR In Number ) ;
--
-- Main
--
  Procedure Full (Verbose In Boolean Default FALSE, 
                  RunAll  In Boolean Default FALSE,
                  VerChk  In Number  Default 5) ;
End hcheck;
/

Create Or Replace Package Body hcheck Is
    Ver        Varchar2(10) := '9i+/hc3.50';
    Warn       Number       :=0            ;
    Fatal      Number       :=0            ;
    CatV       Varchar2(10)                ;
    nCatV      Number       :=0            ;
    Verbose    Boolean                     ;
    nFR        Number       :=0            ; /* Fixed Release */
--
  Function InitsFr Return sFuncRel Is
    AllReleases Varchar2(32) := '99.99.99.99.99' ;
  Begin
--
-- Highest Relevant Release For Functions
-- If check against all releases, specify '99.99.99.99.99'
--
    sFr (0) := AllReleases            ; /*  0 */
    sFr (1) := '10.1.0.2.0'           ; /*  1 */
    sFr (2) := '10.0.0.2.0'           ; /*  2 */
    sFr (3) := AllReleases            ; /*  3 */
    sFr (4) := '10.2.0.1.0'           ; /*  4 */
    sFr (5) := '11.2.0.1.0'           ; /*  5 */
    sFr (6) := '11.2.0.1.0'           ; /*  6 */
    sFr (7) := AllReleases            ; /*  7 */
    sFr (8) :=  '9.0.1.0.0'           ; /*  8 */
    sFr (9) := AllReleases            ; /*  9 */
    sFr(10) := AllReleases            ; /* 10 */
    sFr(11) :=  '9.0.1.0.0'           ; /* 11 */
    sFr(12) := '11.2.0.1.0'           ; /* 12 */
    sFr(13) := AllReleases            ; /* 13 */
    sFr(14) :=  '9.0.1.0.0'           ; /* 13 */
    sFr(15) :=  '9.2.0.1.0'           ; /* 15 */
    sFr(16) := AllReleases            ; /* 16 */
    sFr(17) := AllReleases            ; /* 17 */
    sFr(18) := AllReleases            ; /* 18 */
    sFr(19) := AllReleases            ; /* 19 */
    sFr(20) := AllReleases            ; /* 20 */
    sFr(21) := AllReleases            ; /* 21 */
    sFr(22) := AllReleases            ; /* 22 */
    sFr(23) := AllReleases            ; /* 23 */
    sFr(24) := AllReleases            ; /* 24 */
    sFr(25) := AllReleases            ; /* 25 */
    sFr(26) := AllReleases            ; /* 26 */
    sFr(27) := AllReleases            ; /* 27 */
    sFr(28) := AllReleases            ; /* 28 */
    sFr(29) := AllReleases            ; /* 29 */
    sFr(30) := '11.1.0.6.0'           ; /* 30 */
    sFr(31) := AllReleases            ; /* 31 */
    sFr(32) :=  '8.1.6.0.0'           ; /* 32 */
    sFr(33) :=  '8.0.6.0.0'           ; /* 33 */
    sFr(34) :=  '8.1.7.0.0'           ; /* 34 */
    sFr(35) := AllReleases            ; /* 35 */
    sFr(36) := AllReleases            ; /* 36 */
    sFr(37) := AllReleases            ; /* 37 */
    sFr(38) := AllReleases            ; /* 38 */
    sFr(39) := AllReleases            ; /* 39 */
    sFr(40) := AllReleases            ; /* 40 */
    sFr(41) := '11.1.0.7.0'           ; /* 41 */
    sFr(42) := '11.1.0.7.0'           ; /* 42 */
    sFr(43) := AllReleases            ; /* 43 */
    sFr(44) := '10.1.0.2.0'           ; /* 44 */
    sFr(45) := AllReleases            ; /* 45 */
    sFr(46) := AllReleases            ; /* 46 */
    sFr(47) :=  '9.0.1.0.0'           ; /* 47 */
    sFr(48) :=  '9.0.1.0.0'           ; /* 48 */
    sFr(49) :=  '9.2.0.1.0'           ; /* 49 */
    sFr(50) :=  '9.0.1.0.0'           ; /* 50 */
    sFr(51) := AllReleases            ; /* 51 */
    sFr(52) := AllReleases            ; /* 52 */
    sFr(53) := AllReleases            ; /* 53 */
    sFr(54) := '10.1.0.2.0'           ; /* 54 */
    sFr(55) := AllReleases            ; /* 55 */
    sFr(56) := AllReleases            ; /* 56 */
    sFr(57) := AllReleases            ; /* 57 */
    sFr(58) := AllReleases            ; /* 58 */
    sFr(59) := AllReleases            ; /* 59 */
    sFr(60) := AllReleases            ; /* 60 */
    sFr(61) := AllReleases            ; /* 61 */
    sFr(62) :=  '9.2.0.8.0'           ; /* 62 */
    sFr(63) := '10.1.0.1.0'           ; /* 63 */
    sFr(64) := '10.1.0.1.0'           ; /* 64 */
    sFr(65) :=  '9.2.0.4.0'           ; /* 65 */
    sFr(66) :=  '9.2.0.5.0'           ; /* 66 */
    sFr(67) := '10.2.0.0.0'           ; /* 67 */
    sFr(68) := AllReleases            ; /* 68 */
    sFr(69) := '11.1.0.6.0'           ; /* 69 */
    sFr(70) := AllReleases            ; /* 70 */
    sFr(71) := AllReleases            ; /* 70 */
--
    Return sFr ;
  End ;
--
  Function Owner (uid Number) Return Varchar2 Is
    r          Varchar2(30) := Null        ;
  Begin
    Select name Into r
    From   user$
    where  user# = uid ;

    return r ;
  Exception
    When NO_DATA_FOUND Then
      Return ( '*UnknownOwnID='||uid||'*' ) ;
  End ;
--
  Function ObjName (objid Number) Return Varchar2 Is
    r          Varchar2(30) := Null        ;
    own        Number                      ;
  Begin
    Select name, owner# Into r, own
    From   obj$
    Where  Obj# = objid ;
    return r ;
  Exception
    When NO_DATA_FOUND Then
      Return ( '*UnknownObjID='||objid||'*' ) ;
  End ;
--
  Function IsLastPartition( o number ) Return Boolean Is
    n Number := 0 ;
  Begin
    Select partcnt Into n From partobj$ where obj#=o ;
    If ( n>1 ) Then
      Return(FALSE) ;
    Else
      Return(TRUE) ;
    End If ;
  End;
--
  Function ObjectIsTemporary( o Number ) Return Boolean
  -- Return TRUE if object is a TEMPORARY object
  -- Return NULL if object does not exist
  -- Return FALSE if object is not temporary
  Is
    Cursor cIsTemp Is
      Select Bitand(nvl(flags,0), 2) IsTemp From obj$ Where obj#=o
    ;
    ret Boolean := FALSE ;
  begin
    For R in cIsTemp Loop -- For loop just to keep cursor closed
      If ( R.IsTemp=2 ) Then
        ret := TRUE ; 
      End If;
    End Loop ;
    return ret ;
  End;
--
  Procedure DictAt( ts number, fi number, bl number ) is
   Cursor cDictAt is
     select typ, ts#,file#,block#,count('x') CNT
      from (
    select 'UNDO$' typ, u.ts#, u.file#, u.block# from undo$ u
         where decode(u.status$,1,null,u.status$) is not null
    UNION ALL
    select 'TAB$'        typ, a.ts#,a.file#,a.block# from tab$        a
    UNION ALL
    select 'CLU$'        typ, b.ts#,b.file#,b.block# from clu$        b
    UNION ALL
    select 'TABPART$'    typ, c.ts#,c.file#,c.block# from tabpart$    c
    UNION ALL
    select 'TABSUBPART$' typ, d.ts#,d.file#,d.block# from tabsubpart$ d
    UNION ALL
    select 'IND$'        typ, e.ts#,e.file#,e.block# from ind$        e
    UNION ALL
    select 'INDPART$'    typ, f.ts#,f.file#,f.block# from indpart$    f
    UNION ALL
    select 'INDSUBPART$' typ, g.ts#,g.file#,g.block# from indsubpart$ g
    UNION ALL
    select 'LOB$'        typ, h.ts#,h.file#,h.block# from lob$        h
    UNION ALL
    select 'LOBFRAG$'    typ, i.ts#,i.file#,i.block# from lobfrag$    i
--  UNION ALL
--  select 'RECYCLEBIN$' typ, j.ts#,j.file#,j.block# from recyclebin$ j
       )
       where ts#= TS and file# = FI and block#= BL
       group by typ, ts#,file#,block#
      ;
  Begin
   For R in cDictAt
   Loop
     hout.put_line('^  '||R.typ||' has '||R.cnt||' rows');
   End Loop;
  End;
--
  function IndexIsNosegment( o number ) return boolean is
   Cursor cX is
    select bitand(flags,4096) noseg from ind$ where obj#=o;
   ret boolean:=null;
  begin
   For C in cX
   loop
     if C.noseg=4096 then
    ret:=true;
     else
    ret:=false;
     end if;
   end loop;
   return ret;  /* true/false or NULL if not found */
  end;
--
   Procedure CheckIndPart( o number ) is
    Cursor Cchk is
    select  i.obj#, i.dataobj#, i.ts#, i.file#, i.block#
          from indpart$ i
     where i.bo#=o
       and (i.file#!=0 OR i.block#!=0);
   begin
    For R in Cchk Loop
     hout.put_line(' ^- PROBLEM: Child INDPART$ with FILE/BLK (bug 4683380)');
     hout.put_line(' ^- ( OBJ='||R.obj#|| ' DOBJ='||r.dataobj#||
        ' TS='||r.TS#||
        ' RFILE/BLOCK='||r.file#||' '||r.block#||')' );
     Fatal:=Fatal+1;
    end loop;
   end;
--
  Procedure ChecknCatVnFR ( nCatV In     Number,
                            nFR   In     Number,
                            bRun  In Out Boolean) Is
    str1 Varchar2(10) := To_Char(nCatV) ;
    str2 Varchar2(10) := To_Char(nFR)   ;
  Begin
    Case
      When ( nCatV =          0 ) Then 
        str1 := '*Any Rel*' ;
    Else 
      Null ;
    End Case ;
    Case
      When ( nFR   = 9999999999 ) Then
        str2 := '*All Rel*' ;
      Else
        Null ;
    End Case ;
    If ( nCatV > nFR ) Then
      hout.put_line(Rpad(nCatv,10,' ')||' > '||Lpad(nFR,11,' ')||' : n/a');
      bRun := FALSE ;
      return ;
    Else
      hout.put_line(Rpad(str1,10,' ')||' <='||Lpad(str2,11,' ')||' : Ok') ;
      bRun := TRUE ;
    End If ;
  End ;
--
  Procedure strtok (tok In Out Varchar2, s In Out Varchar2, ct In Varchar2) Is
    i           Pls_integer      ;
    p           Pls_integer      ;
    len         Pls_integer      ;
    token_start Pls_integer      ;
    intoken     Boolean := FALSE ;
  Begin
    -- dbms_output.put_line ( 'strtok string: '||s ) ;
    If ( s Is Not NULL ) Then
      len := length( s ) ;
      i   := 1 ;
      While ( i <= len ) Loop
        p := instr( ct, substr(s,i,1) );
        If ( ( i = len ) Or ( p > 0 ) ) Then
          If ( intoken ) Then
            If ( p > 0 ) Then
              tok := substr( s, token_start, i - token_start ) ;
              s   := substr( s, i+1 ) ;
            Else
              tok := substr( s, token_start, i - token_start + 1 ) ;
              s   := '' ;
            End If ;
            Exit When TRUE ;
          End If ;
        Elsif ( Not intoken ) Then
            intoken := true ;
            token_start := i ;
        End If;
        tok := s ;
        i := i + 1 ;
      End Loop;
    End if;
  End;
--
  Function CatV2nCatV ( s In Varchar2, n in Number default 5 ) Return Number As
    type tok is table of Number index by binary_integer ;
    tk tok ;
    scp varchar2(16) ;
    i number := 1 ;
    scv Varchar2(16) := Null ;
  Begin
    scp := s ;
    for i in 1..n loop
      tk(i) := Null ;
      strtok( tk(i), scp, '.' );
      scv := scv || Lpad(tk(i),2,'0') ;
    end loop ;
    return To_Number(scv) ;
  end;
--
  Procedure SynLastDDLTim
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select Distinct o.obj#, o.owner#, o.name
      From   obj$ o, idl_ub1$ i
      Where  type#  = 5
      And    ctime != mtime
      And    i.obj# = o.obj#    /* Has IDL information */
      ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0001' ;
    ps1a Varchar2(65) := 
         'Synonym''s LAST_DDL_TIME != CREATED' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2371453' ;
    aff1 Varchar2(80) := 'Affects: Vers >=8.1.7.2 and BELOW 10.1 - '||
         'Specifically: 8.1.7.4 9.0.1.3 9.2.0.1' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.5 9.0.1.4 9.2.0.2 10.1.0.2' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 2371453.8 - CREATE OR REPLACE SYNONYM can lead to inconsistent';
    not2 Varchar2(80) := 
         '                  dictionary (old IDL data)' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' OBJ#='||c1.OBJ#||' Name='||Owner(c1.owner#)||'.'||
                      c1.name);
        Warn := Warn + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure LobNotInObj
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select l.obj#, l.lobj#
      From   lob$ l, obj$ o
      Where  l.lobj# = o.obj#(+)
      And    o.obj# is null
      ;
    ps1  Varchar2(10) := 'HCKE-0001' ;
    ps1a Varchar2(65) := 'LOB$.LOBJ# not found in OBJ$' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2405258' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8 and BELOW 10.1 - Specifically: 9.2.0.1' ;
    fix1 Varchar2(80) := 
         'Fixed  : 9.2.0.2 10.1.0.2' ; 
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 2405258.8 - Dictionary corruption / OERI(15265) from MOVE LOB' ;
    not2 Varchar2(80) := 
         '                  to existing segment name' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' LOB$.LOBJ# has no OBJ$ entry for LOBJ#='||c1.lobj#||
                      ' (OBJ#='||c1.obj#||')');
        Fatal := Fatal + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure MissingOIDOnObjCol
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select o.obj# , o.type#, o.owner#, o.name, c.col#, c.intcol#,
               c.name cname, t.property
      From   obj$ o, col$ c, coltype$ ct, oid$ oi, tab$ t
      Where  o.obj#     = ct.obj#
      And    ct.obj#    = c.obj#
      And    ct.col#    = c.col#
      And    ct.intcol# = c.intcol#
      And    oi.oid$(+) = ct.toid
      And    o.obj#     = t.obj#(+)
      And    oi.oid$ is null
      ;
    ps1  Varchar2(10) := 'HCKE-0002' ;
    ps1a Varchar2(65) := 'Object type column with missing OID$' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2728624' ;
    aff1 Varchar2(80) := 
         'Affects: Closed as not a Bug (92)' ;
    fix1 Varchar2(80) := 
         'Fixed  : See Note.229583.1 for patching steps' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note.229583.1 - Bug:2728624 - Confirmation and Patching Notes' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' OBJ#='||c1.obj#||' Name='||Owner(c1.owner#)||'.'
                      ||c1.name||' IntCol#='||c1.intcol#||'='||c1.cname
                      ||' TabProp='||c1.property);
        Fatal := Fatal + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure SourceNotInObj
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select Count('x') cnt, Count(Distinct s.obj#) nobj
      From   source$ s, obj$ o
      Where  s.obj# = o.obj#(+)
      And    o.obj# is null
      Having Count('x') > 0
      ;
    ps1  Varchar2(10) := 'HCKE-0003' ;
    ps1a Varchar2(65) := 'SOURCE$ for OBJ# not in OBJ$' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:3532977' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 10.2   Specifically: 9.2.0.4 10.1.0.4' ;
    fix1 Varchar2(80) := 
         'Fixed  : 9.2.0.8 10.1.0.5 10.2.0.1' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('SOURCE$ has '||c1.cnt||
             ' rows for '||c1.nobj||' OBJ# values not in OBJ$' ) ;
        Fatal := Fatal + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure IndIndparMismatch
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select io.obj# io, io.name ionam, ipo.obj# ipo, ipo.name iponam
      From   obj$ io, indpart$ ip, obj$ ipo
      Where  ipo.type#         = 20  /* IND PART */
      And    ip.obj#           = ipo.obj#
      And    io.obj# (+)       = ip.bo#
      And    nvl(io.name,'"') != ipo.name
      ;
    ps1  Varchar2(10) := 'HCKE-0004' ;
    ps1a Varchar2(65) := 'OBJ$.NAME mismatch for INDEX v INDEX PARTITION' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:3753873' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 11.2 - Specifically: All 9.2 rels '||
         '(9.2.0.4 through 9.2.0.8)' ;
    aff2 Varchar2(80) := 
         '         10.1.0.5 10.2.0.1 10.2.0.2 10.2.0.3 10.2.0.4 11.1.0.7' ;
    fix1 Varchar2(80) := 
         'Fixed  : 11.2.0.1.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note:3753873.8 - Minor dictionary corruption from DROP COLUMN' ;
    not2 Varchar2(80) := 
         '                 of partitioned table with LOB' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (aff2 Is Not Null) Then hout.put_line(aff2); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' Ind Part OBJ$.OBJ# '||c1.ipo||' '||c1.iponam||
                '!='||c1.ionam||' OBJ#='||c1.io);
        Fatal := Fatal + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure InvCorrAudit
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select decode(aud.user#,
                      0, 'ANY CLIENT',
                      1, Null        ,
                      client.name)     username ,
             proxy.name                proxyname,
             prv.name                  privilege,
             decode(aud.success,
                      1, 'BY SESSION',
                      2, 'BY ACCESS' ,
                      'NOT SET')       success  ,
             decode(aud.failure,
                      1, 'BY SESSION',
                      2, 'BY ACCESS' ,
                      'NOT SET')       failure
      From   sys.user$                 client   ,
             sys.user$                 proxy    ,
             system_privilege_map      prv      ,
             sys.audit$                aud
      Where  aud.option# = -prv.privilege
      and aud.user#      = client.user#
      -- and aud.user#     != 1               /* PUBLIC */
      and aud.user#      = 0               /* SYS */
      and aud.proxy#     = proxy.user# (+)
      and aud.proxy# is null
    ;
    ps1  Varchar2(10) := 'HCKE-0005' ;
    ps1a Varchar2(65) := 'Invalid/Corrupted AUDIT$ entries' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:6310840' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 11.2 - Specifically: 11.1.0.6' ;
    fix1 Varchar2(80) := 
         'Fixed  : 11.1.0.7 11.2.0.1' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note.455565.1: Corrupted entries in DBA_PRIV_AUDIT_OPTS' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    variant Varchar2(30) := Null ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        If (c1.username = 'ANY CLIENT')
        Then
          variant := 'Corrupted -' ;
        Else
          variant := 'Invalid   -' ;
        End If ;
        hout.put_line(variant||' USER#='''||c1.username||''' OPTION='''||
                   c1.privilege||''' SUCCESS='''||c1.success||''' FAILURE='''||
                   c1.failure||'''');
        Fatal := Fatal + 1 ;
      End Loop;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OversizedFiles
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select f.ts# TS, f.relfile# RFILE, f.file# AFILE, v.name NAME, f.blocks
      From   ts$ ts, file$ f, v$datafile v
      Where  ts.ts#                = f.ts#
      And    v.file#               = f.file#
      And    f.blocks              > 4194303 -- (4M -1 blocks)
      And    bitand(ts.flags,256) != 256
      Order  By f.ts#, f.relfile#
      ;
    ps1  Varchar2(10) := 'HCKE-0006' ;
    ps1a Varchar2(65) := 'Oversized datafile (blocks>4194303)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' OVERSIZED FILE ('||c1.blocks||' blocks) TS='||c1.TS||
            ' RFILE='||c1.RFILE||
            ' ABS='||c1.AFILE||' Name='||c1.NAME);
        Fatal := Fatal + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure TinyFiles
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      select file#, ts#, blocks
      from   file$
      where  status$ = 2
      and blocks    <= 1
      ;
    ps1  Varchar2(10) := 'HCKE-0007' ;
    ps1a Varchar2(65) := 'Tiny File size in FILE$' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1646512' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 9.0 - Specifically: 8.1.7.3' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.4 9.0.1.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' FILE$ FILE#='||c1.file#||' has BLOCKS='||c1.blocks);
        Fatal := Fatal + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure PoorDefaultStorage
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      select tablespace_name, initial_extent, next_extent, min_extents,
             pct_increase, max_extents
      from   dba_tablespaces
      where (initial_extent < 1024*1024
             or
             contents='TEMPORARY')
       and   next_extent    < 65536
       and   min_extlen     < 65536
       and   pct_increase   <     5
       and   max_extents    >  3000
       ;
    ps1  Varchar2(10) := 'HCKW-0002' ;
    ps1a Varchar2(65) := 'Poor Default Storage Clauses For Tablespace' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note:50380.1 - ALERT: Using UNLIMITED Extent Format' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
          CursorRun := TRUE ;
          hout.put_line(chr(10)||ps1||': '||ps1a);
          hout.put_line('  '||rpad('Tablespace',30)||rpad('Init',10)||
               rpad('Next',10)||rpad('Min',10)||rpad('Pct',4)||
               'MaxExtents');
          ps1:=null;
        End If ;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('  '
            ||rpad(c1.tablespace_name,30)
            ||rpad(c1.initial_extent,10)
            ||rpad(c1.next_extent,10)
            ||rpad(c1.min_extents,10)
            ||rpad(c1.pct_increase,4)
            ||c1.max_extents );
        Warn := Warn + 1 ; 
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure PoorStorage
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select owner       ,
             segment_name,
             segment_type,
             next_extent ,
             extents     ,
             pct_increase,
             max_extents
      From   dba_segments
      Where (     initial_extent < 65535
              And next_extent    < 65536
              And pct_increase   <     5
              And max_extents    >  3000
              And extents        >   500
            ) Or extents         >  3000
    ;
    ps1  Varchar2(10) := 'HCKW-0003' ;
    ps1a Varchar2(65) := 'Poor Storage Clauses For Object(s)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note:50380.1 - ALERT: Using UNLIMITED Extent Format' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
          CursorRun := TRUE ;
          hout.put_line (chr(10)||ps1||': '||ps1a) ;
          ps1:=null;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line('  '||rpad('Segment',50)||rpad('Next',10)||
                        rpad('Exts',7)||rpad('Pct',4)||
                        'MaxExtents' ) ;
        End If;
--
        hout.put_line('  '||
                      rpad(c1.segment_type||' '
                      ||c1.owner||'.'
                      ||c1.segment_name,50)
                      ||rpad(c1.next_extent,10)
                      ||rpad(c1.extents,7)
                      ||rpad(c1.pct_increase,4)
                      ||c1.max_extents );
        Warn := Warn + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure MissTabSubPart
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select o.obj#       part_obj# ,
             o.owner#               ,
             o.name                 ,
             o.subname              ,
             p.subpartcnt           ,
             p.bo#        table_obj#
      From   obj$         o         ,
             tabcompart$  p
      Where  o.type#      = 19      /* PARTITION                     */
      and    o.obj#       = p.obj#  /* Has subpartitions             */
      and    p.subpartcnt = 0       /* Has No entries in tabsubpart$ */
      ;
    Cursor sCur2 Is
      Select o.obj#       part_obj# ,
             o.owner#               ,
             o.name                 ,
             o.subname              ,
             p.subpartcnt           ,
             p.bo#        index_obj#
      from   obj$         o         ,
             indcompart$  p
      where  o.type#      = 20      /* INDEX PARTITION               */
      and    o.obj#       = p.obj#  /* Has subpartitions             */
      and    p.subpartcnt = 0       /* Has No entries in indsubpart$ */
    ;
    ps1  Varchar2(10) := 'HCKE-0008' ;
    ps1a Varchar2(65) := 'Missing TABSUBPART$ entry/entries' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1360714' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8.1.5 and BELOW 9.0 - Specifically: 8.1.7.1' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.2 9.0.1.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    sMsg Boolean      := FALSE ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
--
        hout.put_line(
          ' TABLE '||Owner(c1.owner#)||'.'||c1.name||
          ' Partition '||c1.subname||
          ' PartObj#='||c1.part_obj#||' TabObj#='||c1.table_obj#
        ) ;
        If ( IsLastPartition ( c1.table_obj# ) ) Then
          hout.put_line(' ^^ PARTOBJ$.PARTCNT<=1 - non standard corruption') ;
        End If ;
        If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
        Fatal := Fatal + 1 ;
      End Loop ;
--
      For c2 In sCur2 Loop 
        If (ps1 Is Not Null) Then
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
--
        hout.put_line(
          ' INDEX '||Owner(c2.owner#)||'.'||c2.name||
          ' Partition '||c2.subname||
          ' PartObj#='||c2.part_obj#||' IndObj#='||c2.index_obj#);
        If ( IsLastPartition ( c2.index_obj# ) ) Then
          hout.put_line(' ^^ PARTOBJ$.PARTCNT<=1 - non standard corruption') ;
       End If;
       Fatal := Fatal+1 ;
       sMsg  := TRUE ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
--
      If ( sMsg ) Then
        hout.put_line('There are probably orphaned SEG$ entry/s with this') ;
      End If ;
    End ;
--
  Procedure PartSubPartMismatch
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
       Select po.obj#                              obj#   ,
              u.name owner,
              o.name name,
              Decode(o.type#, 1, 'INDEX', 'TABLE') type   ,
              Decode(po.parttype,
                     1, 'RANGE' ,
                     2, 'HASH'  ,
                     3, 'SYSTEM',
                     4, 'LIST'  ,
                     'Unknown')                    part   ,
              Decode(Mod(po.spare2, 256),
                     0, 'NONE'  ,
                     2, 'HASH'  ,
                     3, 'SYSTEM',
                     4, 'LIST'  ,
                     'Unknown')                    subpart
       From   partobj$                             po     ,
              obj$                                 o      ,
              user$                                u
       Where  po.obj#    = o.obj#
       And    o.owner#   = u.user#
       And    po.spare2 != 0
       And    o.type#    = 1                       -- Index
       And    Decode(po.parttype,
                     1, 'RANGE' ,
                     2, 'HASH'  ,
                     3, 'SYSTEM',
                     4, 'LIST'  ,
                     'Unknown') !=
              Decode(mod(po.spare2, 256),
                     0, 'NONE'  ,
                     2, 'HASH'  ,
                     3, 'SYSTEM',
                     4, 'LIST'  ,
                     'Unknown')
    ;
    ps1  Varchar2(10) := 'HCKW-0004' ;
    ps1a Varchar2(65) := 'TABPART/TABSUBPART method mismatch' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:7509714' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 11.2 - Specifically: 10.2.0.4 10.2.0.5' ; 
    fix1 Varchar2(80) := 
         'Fixed  : 11.2.0.1' ; 
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note:1499.1 - OERR: ORA-1499 table/Index Cross Reference Failure' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0 ) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(
          rpad(' INDEX '||c1.owner||'.'||c1.name,62,' ')||
               ' (OBJ '||c1.obj#||')') ;
        Warn := Warn + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure TabPartCountMismatch
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    nFr  Number ;
    Cursor sCur1 Is
      Select o.obj#                   ,
             o.owner#                 ,
             o.name                   ,
             t.property               ,
             p.partcnt                ,
             Bitand(p.spare2,255) comp
      From   obj$   o,
             tab$   t,
             partobj$ p
      Where  o.type#               =  2                  /* table */
      And    Bitand(t.property,32) = 32      /* partitioned table */
      And    o.obj#                = t.obj#
      And    o.obj#                = p.obj#(+)
      And    o.dataobj# is null
      ;
    Cursor sCur2 ( pobj In Number) Is 
      Select o.obj#    ,
             o.name    ,
             o.subname ,
             o.type#   ,
             o.owner#
      From   obj$ o    ,
             tabpart$ p
      Where  o.obj# = p.obj#
      And    p.bo#  = pobj
      ;
    Cursor sCur3 ( obj In Number ) Is
      Select Count('x') Count From tabcompart$ Where bo#=obj
      ;
    ps1  Varchar2(10) := 'HCKE-0009' ;
    ps1a Varchar2(65) := 'OBJ$-PARTOBJ$-<TABPART$ mismatch' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    nCnt Number       := Null ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 In sCur1 Loop
        --
        -- No Partitions
        --
        If ( c1.partcnt Is Null ) Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line(
            ' OBJ$ has no PARTOBJ$ OBJ#='||c1.obj#||' NAME='||c1.name) ;
          Fatal := Fatal + 1 ;
        Else
          --
          -- Not Composite
          --
          If ( c1.comp=0 ) Then
            Select Count('x') Into nCnt From tabpart$ Where bo#=c1.obj# ;
            --
            -- Interval Partitioned Tables have partcnt = 1048575
            --
            If ( c1.partcnt != nCnt And c1.partcnt != 1048575 ) Then
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line(
                ' PARTOBJ$ PARTCNT!=num TABPART$ rows OBJ#='||c1.obj#||
                ' NAME='||c1.name||' PARTCNT='||c1.partcnt||' CNT='||nCnt
              ) ;
              Fatal := Fatal + 1 ;
            End If ;
            --
            -- Check OBJ$ for the tabpart$ rows match up
            --
            For c2 In sCur2 (c1.obj#) Loop
              If ( c2.name   != c1.name   Or
                   c2.owner# != c1.owner# Or
                   c2.type#  != 19 ) Then
                If (ps1 Is Not Null) Then
                    CursorRun := TRUE ;
                    hout.put_line (chr(10)||ps1||': '||ps1a) ;
                    ps1:=null;
                End If;
                 If ( V ) Then
                  if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                  End If;
                  if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                  End If;
                  if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                  End If;
                  if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                  End If;
                  if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                  End If;
                  hout.put(chr(10)); V := FALSE ;
                End If ;
                hout.put_line(
                  ' TABPART$-OBJ$ mismatch (Bug:1273906)'||
                  ' OBJ#='||c2.obj#||
                  ' #'||c2.owner#||'.'||c2.name||' '||c2.subname) ;
                If ( c2.name != c1.name) Then
                  hout.put_line(
                    '  - Table Name ('||c1.name||') != '||
                    ' Partition Name ('||c2.name||')' );
                End If ;
                If ( c2.owner# != c1.owner# ) Then
                  hout.put_line(
                    '  - Table Owner# ('||c1.owner#||') != '||
                    ' Partition Onwer# ('||c2.owner#||')' );
                End If ;
                If ( c2.type# != 19 ) Then
                  hout.put_line(
                    '  - Partition Type# ('||c2.type#||')!=19' );
                End If ;
                Fatal := Fatal + 1 ;
              End If ;
            End Loop ;
          --
          -- Hash Composite
          --
          ElsIf ( c1.comp=2 ) Then
            For c3 in sCur3 ( c1.obj# ) Loop
              If ( c1.partcnt != c3.Count And c1.partcnt != 1048575 ) Then
                If (ps1 Is Not Null) Then hout.put_line(ps1); ps1:=null; End If;
                CursorRun := TRUE ;
                 If ( V ) Then
                  if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                  End If;
                  if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                  End If;
                  if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                  End If;
                  if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                  End If;
                  if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                  End If;
                  hout.put(chr(10)); V := FALSE ;
                End If ;
                hout.put_line(
                  ' PARTOBJ$ PARTCNT!=num TABCOMPART$ rows OBJ#='||
                  c1.OBJ#||
                  ' NAME='||c1.name||' PARTCNT='||c1.partcnt||' CNT='||
                  c3.Count);
                Fatal := Fatal + 1 ;
              End If ;
            End Loop ;
          End If ;
        End If ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End ;
--
  Procedure OrphanedTabComPart
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select t.obj# , t.bo#, b.name, p.name pname, p.subname, b.owner#
      From   tabcompart$ t, obj$ b, obj$ p
      Where  b.obj#(+) = t.bo#
      And    p.obj#(+) = t.obj#
      And    p.obj#+b.obj# Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0010' ;
    ps1a Varchar2(65) := 'Orphaned TABCOMPART$ from OBJ$' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1528062' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8.1 and BELOW 8.1.7.1   Specifically: 8.1.7.0' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.1 9.0.1.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.1528062.8 - SPLIT PARTITION on composite range-hash partition' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' ORPHAN TABCOMPART$: OBJ='||c1.obj#||
            ' OBJ#Name='||c1.subname||' ('||c1.pname||')'||
            ' BO#='||c1.bo#||
            ' BO#name='||Owner(c1.owner#)||'.'||c1.name);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure ZeroTabSubPart
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    noTable EXCEPTION ;
    PRAGMA EXCEPTION_INIT(noTable, -942) ;
    Cursor sCur1 Is
      Select sp.obj#, sp.ts#, sp.pobj#, b.name, b.subname, b.owner#
      From   indsubpart$ sp, obj$ b
      Where  sp.file#  = 0
      And    sp.block# = 0
      And    b.obj#(+) = sp.pobj#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0011' ;
    ps1a Varchar2(65) := 'INDSUBPART$ has file# = 0' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1614155 (If Also Orphan SEG$)' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8.1 and BELOW 9.2   Specifically: 8.1.7.2 9.0.1.0' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.3 9.0.1.1 9.2.0.1' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.1837529.8: OERI:KFTR2BZ_1/OERI:25012 from CREATE ' ;
    not2 Varchar2(80) := 
         '                sub-partitioned local INDEX ONLINE' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    def_obj    number   := 0 ;
    def_count  number   := 0 ;
    def_exists number   := 1 ;
    sqlstr  varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
    sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      Begin
        Execute Immediate sqlstr Into def_count ;
        Exception
          When noTable Then
            def_exists := 0 ;
      End ;
--
      For c1 in sCur1 Loop
        If ( def_exists = 0 ) Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line(' ORPHAN INDSUBPART$: OBJ#='||c1.obj#||
              ' POBJ#='||c1.pobj#||
              ' Index='||Owner(c1.Owner#)||'.'||c1.name||
              ' Partn='||c1.subname);
          Fatal := Fatal + 1 ;
        Else
          Begin
            Execute Immediate sqlstr1 Into def_obj Using c1.obj# ;
          Exception
            When NO_DATA_FOUND Then
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                End If;
                if (not2 Is Not Null) Then hout.put_line(not2); not2:=null;
                End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line(' ORPHAN INDSUBPART$: OBJ#='||c1.obj#||
                  ' POBJ#='||c1.pobj#||
                  ' Index='||Owner(c1.Owner#)||'.'||c1.name||
                  ' Partn='||c1.subname);
              Fatal := Fatal + 1 ;
          End ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure MissingSum$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select t.obj#,o.owner#,o.name
      From   tab$ t, obj$ o, sum$ s
      Where  bitand(t.flags,262144) = 262144    /* Container table */
      And    o.obj#                 = t.obj#
      And    s.containerobj#(+)     = t.obj#
      And    s.containerobj# Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0012' ;
    ps1a Varchar2(65) := 'SUM$ entry missing for container table' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' TAB$ OBJ#='||c1.OBJ#||' '||Owner(c1.owner#)||'.'||
            c1.name);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure MissingDir$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select o.obj# o_obj, o.owner# o_owner, o.name o_name, d.obj# d_obj,
             oa.grantee# oa_grantee, oa.privilege# oa_priv, u.name u_name
      from   obj$ o, dir$ d, objauth$ oa, user$ u
      where  o.obj# = d.obj# (+)
      and    o.obj# = oa.obj# (+)
      and    o.owner# = u.user#
      and    o.type# = 23
      and    d.obj# is null
      ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0013' ;
    ps1a Varchar2(65) := 'DIR$ entry missing for directory objects' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(' OBJ$ OBJ#='||c1.o_obj||' Owner='||c1.u_name||'.'||
             c1.o_name||' - Grantee('||c1.oa_grantee||') - Priv ('||
             c1.oa_priv||')');
        Fatal:=Fatal+1;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure DuplicateDataobj
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select * from
      (
        Select /*+ NO_MERGE */
               many.dataobj#,
               o.obj#,
               o.owner#,
               o.name,
               o.subname,
               o.type#,
               t.property
        From (
               Select dataobj#
               From   obj$
               Where  dataobj# is not null
               Group  By dataobj#
               Having Count('x') > 1
             ) many, obj$ o, tab$ t
        Where  many.dataobj# = o.dataobj#(+)
        And    o.type# (+)  != 3              /* Not a cluster        */
        And    t.obj#  (+)   = o.obj#
      )
      Where  Bitand(property, 1024)!=1024     /* Not a cluster table  */
      And    Bitand(property, 64)  !=64       /* Not an IOT           */
--    Or     property is null                 /* IOT Part's fall here */
      Order  By dataobj#, obj#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0014' ;
    ps1a Varchar2(65) := 'Dup. dataobj#'||
                         Chr(10)||
                         'May be valid under the following:' ;
    ps1b Varchar2(80) := '* Using TTS' ;
    ps1c Varchar2(80) := '* Obj''s belong to different TS''s'||Chr(10) ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2597763 (If Dup SubPart found)' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 10.1' ;
    fix1 Varchar2(80) := 
         'Fixed  : 9.2.0.7 10.1.0.2' ;
    not1 Varchar2(80) := 
         'Note.2597763.8: SPLIT of a COMPOSITE PARTITION (Dup dataobj#)' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    sub boolean := FALSE ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            hout.put_line ('    '||ps1b) ;
            hout.put_line ('    '||ps1c) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('DATAOBJ#='||c1.DATAOBJ#||' OBJ#='||c1.obj#||
            ' Name='||Owner(c1.owner#)||'.'||c1.name||' '||c1.subname||
            ' Type#='||c1.type#) ;
        If (c1.type#=34 /*table subpart*/) Then
          sub := TRUE ;
        End If;
        Fatal:=Fatal+1;
      End Loop ; 
      If ( sub ) Then
        hout.put_line('Subpartition duplicates (type# 34) found') ;
      End If;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure ObjSynMissing
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#, o.owner#, o.name
      From   obj$ o, syn$ s
      Where  o.type#    = 5
      And    o.obj#     = s.obj#(+)
      And    o.linkname Is Null          /* Not a remote object */
      And    s.obj#     Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0005' ;
    ps1a Varchar2(65) := 'SYN$ entry missing for OBJ$ type#=5' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ#='||c1.OBJ#||' Name='||Owner(c1.owner#)||'.'||
            c1.name);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure ObjSeqMissing
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#, o.owner#, o.name
      From obj$ o, seq$ s
      Where o.type#    = 6
      And   o.obj#     = s.obj#(+)
      And   o.linkname is null            /* Not remote */
      And   s.obj#     is null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0006' ;
    ps1a Varchar2(65) := 'SEQ$ entry missing for OBJ$ type#=6' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ#='||c1.OBJ#||' Name='||Owner(c1.owner#)||'.'||
            c1.name);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedUndo
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
     select u.us#            u_us,
            u.name           u_name,
            u.ts#            u_ts,
        nvl(s.ts#,0)     s_ts,
        u.file#          u_file,
        nvl(s.file#,0)   s_file,
        u.block#         u_block,
        nvl(s.block#,0)  s_block,
        u.status$        u_status,
            nvl(s.type#,0)   s_type
     from   undo$            u,
            seg$             s
     where  u.ts#           = s.ts#    (+)
     and    u.file#         = s.file#  (+)
     and    u.block#        = s.block# (+)
     and    u.status$       > 1
     and    nvl(s.type#,0) != 1
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0015' ;
    ps1a Varchar2(65) := 'Orphaned Undo$ (no SEG$)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.270386.1 - ORA-600 [ktssdrp1] / [ktsiseginfo1] '||
         '/ [4042]: undo$ <-> seg$' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If ((c1.s_ts    != c1.u_ts)   Or
            (c1.s_file  != c1.u_file) Or
            (c1.s_block != c1.u_block))
        Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line('ORPHAN UNDO$: US#='||c1.u_us||
              ' NAME='||c1.u_name||
              ' RFILE/BLOCK='||c1.u_file||' '||c1.u_block||
              ' STATUS$='||c1.u_status);
          Fatal := Fatal + 1 ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedIndex
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    noTable EXCEPTION ;
    PRAGMA EXCEPTION_INIT(noTable, -942) ;
    Cursor sCur1 Is
      Select i.obj#, i.dataobj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
      From   seg$ s, ind$ i
      Where  i.ts#                 = s.ts#(+)
      And    i.file#               = s.file#(+)
      And    i.block#              = s.block#(+)
      And    Bitand(i.flags,4096) != 4096  /* Exclude NOSEGMENT index */
      And    Nvl(s.type#,0)       != 6
      And    i.dataobj# Is Not Null        /* ie: A Physical object   */
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0016' ;
    ps1a Varchar2(65) := 'Orphaned IND$ (no SEG$)' ;
    bug1 Varchar2(80) := 
                         'Ref    : Bug:3655873/Bug:3082770 (Ongoing) '||
                         '- Tue Jun 14 14:11:24 CEST 2011' ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    def_obj    number   := 0 ;
    def_count  number   := 0 ;
    def_exists number   := 1 ;
    sqlstr  varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
    sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
    ind_flags number ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      Begin
        Execute Immediate sqlstr Into def_count ;
        Exception
          When noTable Then
            def_exists := 0 ;
      End ;
--
      For c1 in sCur1 Loop
        Begin
          If ( ObjectIsTemporary(c1.obj#)) Then
            Null ; -- this is ok
          Else
            Select o.flags Into ind_flags
            From   obj$ o
            Where obj# = c1.bo#
            ;
            If ( ind_flags != 2 ) Then                 /* 0x02 -> Global Temp */
              If ( def_exists = 0 ) Then
                If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
                End If;
                 If ( V ) Then
                  if (bug1 Is Not Null) Then hout.put_line(bug1);
                      bug1:=null; End If;
                  if (aff1 Is Not Null) Then hout.put_line(aff1);
                      aff1:=null; End If;
                  if (fix1 Is Not Null) Then hout.put_line(fix1);
                      fix1:=null; End If;
                  if (tag1 Is Not Null) Then hout.put_line(tag1);
                      tag1:=null; End If;
                  if (not1 Is Not Null) Then hout.put_line(not1);
                      not1:=null; End If;
                  hout.put(chr(10)); V := FALSE ;
                End If ;
                hout.put_line('ORPHAN IND$: OBJ='||c1.obj#||
                    ' DOBJ='||c1.dataobj#||
                    ' TS='||c1.TS#||
                    ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                    ' BO#='||c1.bo#||' SegType='||c1.type#);
                If ( c1.TS#=0 And c1.file#=0 And c1.block#=0 ) Then
                  hout.put_line('^- May be OK. Needs manual check');
                End If ;
                Fatal:=Fatal+1;
              Else
                Begin
                  Execute Immediate sqlstr1 Into def_obj Using c1.obj# ;
                Exception
                  When NO_DATA_FOUND Then
                    If (ps1 Is Not Null) Then
                      CursorRun := TRUE ;
                      hout.put_line (chr(10)||ps1||': '||ps1a) ;
                      ps1:=null;
                    End If;
                    If ( V ) Then
                      if (bug1 Is Not Null) Then hout.put_line(bug1);
                          bug1:=null; End If;
                      if (aff1 Is Not Null) Then hout.put_line(aff1);
                          aff1:=null; End If;
                      if (fix1 Is Not Null) Then hout.put_line(fix1);
                          fix1:=null; End If;
                      if (tag1 Is Not Null) Then hout.put_line(tag1);
                          tag1:=null; End If;
                      if (not1 Is Not Null) Then hout.put_line(not1);
                          not1:=null; End If;
                      hout.put(chr(10)); V := FALSE ;
                    End If ;
                    hout.put_line('ORPHAN IND$: OBJ='||c1.obj#||
                                   ' DOBJ='||c1.dataobj#||
                                   ' TS='||c1.TS#||
                                   ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                                   ' BO#='||c1.bo#||' SegType='||c1.type#);
                    If ( c1.TS#=0 And c1.file#=0 And c1.block#=0 ) Then
                      hout.put_line('^- May be OK. Needs manual check');
                    End If ;
                    Fatal := Fatal + 1 ;
                End ;
              End If ;
            End If ;
          End If ;
        Exception
          When NO_DATA_FOUND Then
            If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
            End If;
            If ( V ) Then
              if (bug1 Is Not Null) Then hout.put_line(bug1);
                  bug1:=null; End If;
              if (aff1 Is Not Null) Then hout.put_line(aff1);
                  aff1:=null; End If;
              if (fix1 Is Not Null) Then hout.put_line(fix1);
                  fix1:=null; End If;
              if (tag1 Is Not Null) Then hout.put_line(tag1);
                  tag1:=null; End If;
              if (not1 Is Not Null) Then hout.put_line(not1);
                  not1:=null; End If;
              hout.put(chr(10)); V := FALSE ;
            End If ;
            -- CursorRun := TRUE ;
            hout.put_line('ORPHAN IND$: OBJ='||c1.obj#||
                ' DOBJ='||c1.dataobj#||
                ' TS='||c1.TS#||
                ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                ' BO#='||c1.bo#||' SegType='||c1.type#);
            If ( c1.TS#=0 And c1.file#=0 And c1.block#=0) Then
              hout.put_line('^- May be OK. Needs manual check');
            End If;
            Fatal := Fatal + 1 ;
        End ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedIndexPartition
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    noTable EXCEPTION ;
    PRAGMA EXCEPTION_INIT(noTable, -942) ;
    Cursor sCur1 Is
      select i.obj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
      from   seg$ s, indpart$ i
      where  i.ts#=s.ts#(+)
      and    i.file#=s.file#(+)
      and    i.block#=s.block#(+)
      and    i.dataobj# is not null   /* ie: A Physical object */
      and nvl(s.type#,0)!=6
      and not (i.ts#=0 and i.file#=0 and i.block#=0) /* TEMP */
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0017' ;
    ps1a Varchar2(65) := 'Orphaned INDPART$ (no SEG$)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    def_obj    number    := 0 ;
    def_count  number    := 0 ;
    def_exists number    := 1 ;
    sqlstr  varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
    sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
    noseg Boolean        := FALSE ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      Begin
        Execute Immediate sqlstr Into def_count ;
        Exception
          When noTable Then
            def_exists := 0 ;
      End ;
--
      For c1 in sCur1 Loop
        noseg := IndexIsNosegment(c1.bo#) ;
        If (def_exists = 0) Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line('ORPHAN INDPART$: OBJ='||c1.obj#||
              ' TS='||c1.TS#||
              ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
              ' BO#='||c1.bo#||' SegType='||c1.type#);
          Fatal := Fatal + 1 ;
        Else
          If (noseg Is Null OR noseg = FALSE) Then
            Begin
              Execute Immediate sqlstr1 into def_obj Using c1.obj# ;
              Exception
                When NO_DATA_FOUND Then
                  If (ps1 Is Not Null) Then
                      CursorRun := TRUE ;
                      hout.put_line (chr(10)||ps1||': '||ps1a) ;
                      ps1:=null;
                  End If;
                   If ( V ) Then
                    if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                        End If;
                    if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                        End If;
                    if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                        End If;
                    if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                        End If;
                    if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                        End If;
                    hout.put(chr(10)); V := FALSE ;
                  End If ;
                  hout.put_line('ORPHAN INDPART$: OBJ='||c1.obj#||
                      ' TS='||c1.TS#||
                      ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                      ' BO#='||c1.bo#||' SegType='||c1.type#);
                  Fatal := Fatal + 1 ;
            End ;
          End If ;
        End If ;
        If (noseg Is Null) Then
          hout.put_line('^- INDPART$ (BO#) has no IND$ entry');
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedIndexSubPartition
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    noTable EXCEPTION ;
    PRAGMA EXCEPTION_INIT(noTable, -942) ;
    Cursor sCur1 Is
    select i.obj#, i.ts#, i.file#, i.block#, i.pobj#, s.type#
          from seg$ s, indsubpart$ i
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
           and i.dataobj# is not null   /* ie: A Physical object */
       and not (i.ts#=0 and i.file#=0 and i.block#=0) /* TEMP */
           and nvl(s.type#,0)!=6
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0018' ;
    ps1a Varchar2(65) := 'Orphaned INDSUBPART$ (no SEG$)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    def_obj    number    := 0 ;
    def_count  number    := 0 ;
    def_exists number    := 1 ;
    sqlstr  varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
    sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      Begin
        Execute Immediate sqlstr Into def_count ;
        Exception
          When noTable Then
            def_exists := 0 ;
      End ;
--
      For c1 in sCur1 Loop
        If (def_exists = 0) Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line('ORPHAN INDSUBPART$: OBJ='||c1.obj#||
              ' TS='||c1.TS#||
              ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
              ' POBJ#='||c1.pobj#||' SegType='||c1.type#);
          Fatal := Fatal + 1 ;
        Else
          Begin
            Execute Immediate sqlstr1 Into def_obj Using c1.obj# ;
          Exception
            When NO_DATA_FOUND Then
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                    End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                    End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                    End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                    End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                    End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line('ORPHAN INDSUBPART$: OBJ='||c1.obj#||
                  ' TS='||c1.TS#||
                  ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                  ' POBJ#='||c1.pobj#||' SegType='||c1.type#);
              Fatal := Fatal + 1 ;
          End ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedTable
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    noTable EXCEPTION ;
    PRAGMA EXCEPTION_INIT(noTable, -942) ;
    Cursor sCur1 Is
      select i.obj#, i.dataobj#, i.ts#, i.file#, i.block#, i.bobj#, s.type#,
             bitand(i.property,64) iot
      from   seg$ s, tab$ i
      where  i.ts#                  = s.ts#(+)
      and    i.file#                = s.file#(+)
      and    i.block#               = s.block#(+)
      and    nvl(s.type#,0)        != 5
      and    bitand(i.property,64) != 64 /*(So that we exclude iot's) */
      and    i.dataobj# is not null   /* ie: A Physical object */
      /* and not (i.ts#=0 and i.file#=0 and i.block#=0) /* TEMP */
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0019' ;
    ps1a Varchar2(65) := 'Orphaned TAB$ (no SEG$)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    def_obj    number   := 0 ;
    def_count  number   := 0 ;
    def_exists number   := 1 ;
    sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
    sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      Begin
        Execute Immediate sqlstr Into def_count ;
      Exception
        When noTable Then
          def_exists := 0 ;
      End ;
--
      For c1 in sCur1 Loop
        If (ObjectIsTemporary(c1.obj#)) Then
          Null ; -- this is ok
        Else
          If ( c1.iot=64 And c1.dataobj#=0 And c1.ts#=0 and c1.block#=0) Then
            Null ; -- this is a truncated IOT (See 4701060)
          Else
            If (def_exists=0) Then
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                    End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                    End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                    End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                    End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                    End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line('ORPHAN TAB$: OBJ='||c1.obj#||
                  ' DOBJ='||c1.dataobj#||
                  ' TS='||c1.TS#||
                  ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                  ' BOBJ#='||c1.bobj#||' SegType='||c1.type#);
              If (c1.TS#=0 and c1.file#=0 and c1.block#=0) Then
                hout.put_line('^- May be OK. Needs manual check');
              End If ;
              Fatal := Fatal + 1 ;
            Else
              Begin
                Execute Immediate sqlstr1 Into def_obj Using c1.obj# ;
              Exception
                When NO_DATA_FOUND Then
                  If (ps1 Is Not Null) Then
                      CursorRun := TRUE ;
                      hout.put_line (chr(10)||ps1||': '||ps1a) ;
                      ps1:=null;
                  End If;
                   If ( V ) Then
                    if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                        End If;
                    if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                        End If;
                    if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                        End If;
                    if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                        End If;
                    if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                        End If;
                    hout.put(chr(10)); V := FALSE ;
                  End If ;
                  hout.put_line('ORPHAN TAB$: OBJ='||c1.obj#||
                      ' DOBJ='||c1.dataobj#||
                      ' TS='||c1.TS#||
                      ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                      ' BOBJ#='||c1.bobj#||' SegType='||c1.type#);
                  If (c1.TS#=0 and c1.file#=0 and c1.block#=0) Then
                    hout.put_line('^- May be OK. Needs manual check');
                  End If ;
                  Fatal := Fatal + 1 ;
              End ;
            End If ;
          End If ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedTablePartition
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    noTable EXCEPTION ;
    PRAGMA EXCEPTION_INIT(noTable, -942) ;
    Cursor sCur1 Is
        select i.obj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
          from seg$ s, tabpart$ i, tab$ t
         where i.ts#=s.ts#(+)
           and i.file#=s.file#(+)
           and i.block#=s.block#(+)
           and i.dataobj# is not null   /* ie: A Physical object */
           and i.bo# = t.obj#
           and not (i.ts#=0 and i.file#=0 and i.block#=0) /* TEMP */
           and nvl(s.type#,0)!=5
           and bitand(t.property,64)!=64 /*(So that we exclude iot's) */
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0020' ;
    ps1a Varchar2(65) := 'Orphaned TABPART$ (no SEG$)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    def_obj    number   := 0 ;
    def_count  number   := 0 ;
    def_exists number   := 1 ;
    sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
    sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      Begin
        Execute Immediate sqlstr Into def_count ;
        Exception
          When noTable Then
            def_exists := 0 ;
      End ;
--
      For c1 in sCur1 Loop
        If (def_exists = 0) Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line('ORPHAN TABPART$: OBJ='||c1.obj#||
              ' TS='||c1.TS#||
              ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
              ' BO#='||c1.bo#||' SegType='||c1.type#);
          If (c1.TS#=0 and c1.file#=0 and c1.block#=0) Then
            hout.put_line('^- May be OK. Needs manual check');
          End If ;
          Fatal:=Fatal+1;
        Else
          Begin
            Execute Immediate sqlstr1 Into def_obj Using c1.obj# ;
          Exception
            When NO_DATA_FOUND Then
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                    End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                    End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                    End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                    End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                    End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line('ORPHAN TABPART$: OBJ='||c1.obj#||
                  ' TS='||c1.TS#||
                  ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                  ' BO#='||c1.bo#||' SegType='||c1.type#);
              If (c1.TS#=0 and c1.file#=0 and c1.block#=0) Then
                hout.put_line('^- May be OK. Needs manual check');
              End If ;
              Fatal:=Fatal+1;
          End ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedTableSubPartition
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    noTable EXCEPTION ;
    PRAGMA EXCEPTION_INIT(noTable, -942) ;

    Cursor sCur1 Is
        select tsp.obj#, tsp.ts#, tsp.file#, tsp.block#, tsp.pobj#, s.type#
          from obj$ o, tabcompart$ tcp, tabsubpart$ tsp, seg$ s
         where o.obj#     = tcp.obj#
           and tcp.obj#   = tsp.pobj#
           and tsp.ts#    = s.ts#     (+)
           and tsp.file#  = s.file#   (+)
           and tsp.block# = s.block#  (+)
           and s.file# is null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0021' ;
    ps1a Varchar2(65) := 'Orphaned TABSUBPART$ (no SEG$)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    def_obj    number   := 0 ;
    def_count  number   := 0 ;
    def_exists number   := 1 ;
    sqlstr varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
    sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
    Begin
      Execute Immediate sqlstr Into def_count ;
    Exception
      When noTable Then
        def_exists := 0 ;
    End ;
--
      For c1 in sCur1 Loop
        If (def_exists = 0) Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line('ORPHAN TABSUBPART$: OBJ='||c1.obj#||
              ' TS='||c1.TS#||
              ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
              ' POBJ#='||c1.pobj#||' SegType='||c1.type#);
          Fatal := Fatal + 1 ;
        Else
          Begin
            Execute Immediate sqlstr1 Into def_obj Using c1.obj# ;
          Exception
            When NO_DATA_FOUND Then
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                    End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                    End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                    End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                    End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                    End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line('ORPHAN TABSUBPART$: OBJ='||c1.obj#||
                  ' TS='||c1.TS#||
                  ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
                  ' POBJ#='||c1.pobj#||' SegType='||c1.type#);
              Fatal := Fatal + 1 ;
          End ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure MissingPartCol
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select tp.bo#, tp.obj#, tp.ts#, tp.file#, tp.block#, o.type#
      From   tabpart$ tp, partcol$ pc, obj$ o
      Where  tp.bo#   = pc.obj# (+)
      And    tp.obj#  = o.obj#
      And    pc.obj# Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0022' ;
    ps1a Varchar2(65) := 'Missing TabPart Column (no PARTCOL$ info)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Drop Table -> ORA-600 [kkpodDictPcol1], [1403], [0]' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
          hout.put_line('MISSING PARTCOL$: OBJ='||c1.bo#||
              ' DOBJ='||c1.obj#||
              ' TS='||c1.ts#||
              ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
              ' SegType='||c1.type#);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedSeg$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select 'TYPE2 UNDO' typ, s.ts#, s.file#, s.block#
      From   seg$ s, undo$ u
      Where  s.ts#    = u.ts#(+)
      And    s.file#  = u.file#(+)
      And    s.block# = u.block#(+)
      And    s.type#  = 10
      -- And u.file# Is Null
      And    Decode(u.status$,1,null,u.status$) Is Null
      UNION ALL
      Select 'UNDO' typ, s.ts#, s.file#, s.block#
      From   seg$ s, undo$ i
      Where  s.ts#    = i.ts#(+)
      And    s.file#  = i.file#(+)
      And    s.block# = i.block#(+)
      And    s.type#  = 1
      -- And i.file# Is Null
      And    Decode(i.status$,1,null,i.status$) Is Null
      UNION ALL
      Select 'DATA' typ, s.ts#, s.file#, s.block#
      From   seg$ s,
      ( Select a.ts#,a.file#,a.block# From tab$ a
        UNION ALL
        Select b.ts#,b.file#,b.block# From clu$ b
        UNION ALL
        Select c.ts#,c.file#,c.block# From tabpart$ c
        UNION ALL
        Select d.ts#,d.file#,d.block# From tabsubpart$ d
      ) i
      Where s.ts#    = i.ts#(+)
      And   s.file#  = i.file#(+)
      And   s.block# = i.block#(+)
      And   s.type#  = 5
      And   i.file# Is Null
      UNION ALL
      Select 'INDEX' typ, s.ts#, s.file#, s.block#
      From seg$ s,
      ( Select a.ts#,a.file#,a.block# From ind$ a
        UNION ALL
        Select b.ts#,b.file#,b.block# From indpart$ b
        UNION ALL
        Select d.ts#,d.file#,d.block# From indsubpart$ d
      ) i
      Where  s.ts#    = i.ts#(+)
      And    s.file#  = i.file#(+)
      And    s.block# = i.block#(+)
      And    s.type#  = 6
      And    i.file# Is Null
      UNION ALL
      Select 'LOB' typ, s.ts#, s.file#, s.block#
      From   seg$ s, lob$ i --, sys_objects so
      Where  s.ts#    = i.ts#(+)
      And    s.file#  = i.file#(+)
      And    s.block# = i.block#(+)
      And    s.type#  = 8
      And    i.file# Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0023' ;
    ps1a Varchar2(65) := 'Orphaned SEG$ Entry' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    so_type Number ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If ( c1.typ = 'LOB' ) Then
          Begin
            Select so.object_type_id Into so_type
            From   sys_objects so
            Where  so.ts_number    = c1.ts#
            And    so.header_file  = c1.file#
            And    so.header_block = c1.block# ;
            If ( so_type Not In (40, 41) ) Then     /* Object Found */
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                    End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                    End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                    End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                    End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                    End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line('ORPHAN SEG$: SegType='||c1.typ||
                  ' TS='||c1.TS#||
                  ' RFILE/BLOCK='||c1.file#||' '||c1.block#);
              Fatal := Fatal + 1 ;
            End If ;
          Exception
            When NO_DATA_FOUND Then
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                    End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                    End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                    End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                    End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                    End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line('ORPHAN SEG$: SegType='||c1.typ||
                  ' TS='||c1.TS#||
                  ' RFILE/BLOCK='||c1.file#||' '||c1.block#);
              Fatal := Fatal + 1 ;
          End ;
        End If ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanedIndPartObj#
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select i.obj#, i.ts#, i.file#, i.block#, i.bo#
      From   obj$ o, indpart$ i
      Where  o.obj#(+) = i.obj#
      And    o.obj# Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0024' ;
    ps1a Varchar2(65) := 'Orphaned Index Partition Obj# (no OBJ$)' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:5040222' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 11.1 Specifically: 10.1.0.5 10.2.0.2' ;
    fix1 Varchar2(80) := 
         'Fixed  : 10.2.0.3 11.1.0.6' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.5040222.8: OERI[4823] from drop partition table after' ;
    not2 Varchar2(80) := 
         '                merge with update indexes' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('ORPHAN INDPART$: OBJ#='||c1.obj#||' - no OBJ$ row');
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure DuplicateBlockUse
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select ts#,file#,block#,count('x') CNT, min(typ) mintyp
      From
      (
        Select 'UNDO$' typ, u.ts#, u.file#, u.block# from undo$ u
        Where Decode(u.status$,1,null,u.status$) Is Not Null
        UNION ALL
        Select 'TAB$', a.ts#,a.file#,a.block# From tab$ a
        UNION ALL
        Select 'CLU$', b.ts#,b.file#,b.block# From clu$ b
        UNION ALL
        Select 'TABPART$', c.ts#,c.file#,c.block# From tabpart$ c
        UNION ALL
        Select 'TABSUBPART$', d.ts#,d.file#,d.block# From tabsubpart$ d
        UNION ALL
        Select 'IND$', a.ts#,a.file#,a.block# From ind$ a
        UNION ALL
        Select 'INDPART$', b.ts#,b.file#,b.block# From indpart$ b
        UNION ALL
        Select 'INDSUBPART$', d.ts#,d.file#,d.block# From indsubpart$ d
        UNION ALL
        Select 'LOB$' , i.ts#, i.file#, i.block# From lob$ i
        UNION ALL
        Select 'LOBFRAG$' , i.ts#, i.file#, i.block# From lobfrag$ i
        --  UNION ALL
        --  select 'RECYCLEBIN$' , i.ts#, i.file#, i.block# From recyclebin$ i
      )
      Where  block#    != 0
      Group  By ts#, file#, block#
      Having Count('x') > 1
      And    Min(typ)  != 'CLU$'  /* CLUSTER can have multiple entries */
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0025' ;
    ps1a Varchar2(65) := 'Block has multiple dictionary entries' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('MULTI DICT REF: TS='||c1.TS#||
            ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
            ' cnt='||c1.cnt);
        DictAt(c1.ts#, c1.file#, c1.block#);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure HighObjectIds
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select max(obj#) maxobj, max(dataobj#) maxdobj From obj$
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0026' ;
    ps1a Varchar2(65) := 'High Objects IDS exist' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:970640' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8.1.5 and BELOW 8.1.6' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.6.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.76746.1: Script to check DB Corr due to Bug.970640' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (c1.maxobj>2000000000) or (c1.maxdobj>2000000000) Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line('HIGH OBJECT NUMBERS EXIST: max(OBJ)='||c1.maxobj||
              ' max(dataobj#)='||c1.maxdobj);
          Fatal := Fatal + 1 ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure PQsequence
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select max_value, cycle_flag, last_number
      From   DBA_SEQUENCES
      Where  sequence_owner = 'SYS'
      And    sequence_name  = 'ORA_TQ_BASE$'
      And    cycle_flag    != 'Y'
      And    last_number    > 1000000
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0007' ;
    ps1a Varchar2(65) := 'Parallel Query internal sequence exhaustion' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:725220' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 8.0.6' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.0.6.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.66450.1: PQ internal sequence exceeds 4294967' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('ORA_TQ_BASE$ is not CYCLIC - '||
            To_char(c1.max_value-c1.last_number)||' values left');
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure TruncatedCluster
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
    select /*+ ORDERED */
        t.obj#, u.name owner, o.name, t.dataobj# td, c.dataobj# cd
      from clu$ c, tab$ t, obj$ o, user$ u
     where t.ts# = c.ts#
       and   t.file# = c.file#
       and   t.block# = c.block#
       and   t.dataobj# != c.dataobj#
       and   t.obj# = o. obj#
       and   o.owner# = u.user#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0027' ;
    ps1a Varchar2(65) := 'Clustered Tables with bad DATAOBJ#' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1283521' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8.0 and BELOW 8.1.7' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.109134.1: Bad Cluster DATAOBJ# - Confirmation and Patching' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('Bad TAB$ entry: TAB OBJ='||c1.obj#||
            ' NAME='||c1.owner||'.'||c1.name||
            ' Tab DOBJ='||c1.td||' != '||c1.cd) ;
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure FetUet
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select ts#
      From   ts$
      Where  online$   != 3   /* Not INVALID        */
      And    bitmapped  = 0   /* Dictionary Managed */
    ;
    Cursor sCur2 (ts In Number) Is
               Select relfile#, blocks
               From   file$
               Where  ts#      = ts
               And    status$ != 1 
               ;
    Cursor sCur3 (ts In Number, fil In Number, len In Number) Is
               Select block#, length, 'FET$' typ
               From   fet$
               Where  ts#   = ts
               And    file# = fil
               UNION  ALL
               select block#, length, 'UET$' typ
               from   uet$
               where  ts#   = ts
               And    file# = fil
               Order  By 1 
               ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0028' ;
    ps1a Varchar2(65) := 'FET$ <-> UET$ Corruption ' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    BlkExpected Number       ;
    prev        sCur3%Rowtype;
    relfile     Number       ;
    blocks1     Number       ;
    blocks2     Number       ;
    len         Number       ; 
    typ         Varchar2(4)  ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        For c2 in sCur2 (c1.ts#) Loop
          BlkExpected := 2 ;
          prev.typ := Null ; prev.block# := Null ; prev.length := Null ;
          For c3 in sCur3 (c1.ts#, c2.relfile#, c2.blocks) Loop
            If ( c3.block# != BlkExpected ) Then
              If (ps1 Is Not Null) Then
                  CursorRun := TRUE ;
                  hout.put_line (chr(10)||ps1||': '||ps1a||'TS# = '||c1.ts#||
                      ' - rFil = '||c2.relfile#) ;
                  ps1:=null;
              End If;
               If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                    End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                    End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                    End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                    End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                    End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
            End If ;
            Case 
              When ( c3.block# = BlkExpected ) Then
                Null ;
              When ( c3.block# < BlkExpected ) Then
                hout.put_line('OVERLAP: TS#='||c1.ts#||' RFILE='||c2.relfile#||
                    ' ('||prev.typ||' '||prev.block#||' '||prev.length||
                    ') overlaps ('||
                    c3.typ||' '||c3.block#||' '||c3.length||')');
                Fatal := Fatal + 1 ;
              When ( c3.block# > BlkExpected ) Then
                hout.put_line('GAP    : TS#='||c1.ts#||' RFILE='||c2.relfile#||
                    ' ('||prev.typ||' '||prev.block#||' '||prev.length||
                    ') overlaps ('||
                    c3.typ||' '||c3.block#||' '||c3.length||')');
                Fatal := Fatal + 1 ;
            End Case ;
            prev := c3 ;
            BlkExpected := c3.block# + c3.length ;
          End Loop ;
          If ( BlkExpected-1 != c2.blocks ) Then
            If (ps1 Is Not Null) Then
                CursorRun := TRUE ;
                hout.put_line (chr(10)||ps1||': '||ps1a||'TS# = '||c1.ts#||
                    ' - rFil = '||c2.relfile#) ;
                ps1:=null;
            End If;
            If ( V ) Then
              if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                  End If;
              if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                  End If;
              if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                  End If;
              if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                  End If;
              if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                  End If;
              hout.put(chr(10)); V := FALSE ;
            End If ;
            -- c1.ts#, c2.relfile#, c2.blocks
            If (BlkExpected-1>len) then
              hout.put_line(' EXTENT past end of file: TS#='||c1.ts#||' RFILE='
                  ||c2.relfile#||' ('||prev.typ||' '||prev.block#||' '||
                  prev.length||') goes past end of file ('||c2.blocks||
                  ' blocks)');
            Else
              hout.put_line(' EXTENT too short: TS#='||c1.ts#||' RFILE='||
              c2.relfile#||' ('||prev.typ||' '||prev.block#||' '||prev.length||
              ') does not reach end of file ('||c2.blocks||' blocks)');
            End If ;
          End If ;
        End Loop ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure Uet0Check
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select ts#, segfile#, segblock#, file#, block#
      From   uet$ 
      Where  ext# = 0
      And   (file# != segfile# Or block# != segblock#)
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0029' ;
    ps1a Varchar2(65) := 'EXTENT 0 not at start of segment' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('TS#='||c1.ts#||
            ' '||c1.segfile#||','||c1.segblock#||' != '||
            c1.file#||','||c1.block#);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure ExtentlessSeg
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select s.ts#, s.file#, s.block#, s.type#
      From   seg$ s, uet$ u
      Where  s.ts#                      = u.ts#(+)
      And    s.file#                    = u.segfile#(+)
      And    s.block#                   = u.segblock#(+)
      And    bitand(NVL(s.spare1,0), 1) = 0 /* Not locally managed */
      And    u.ext#(+)                  = 0
      And    u.ts# Is Null                  /* no UET$ entry       */
      Order  By s.ts#, s.file#, s.block#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0008' ;
    ps1a Varchar2(65) := 'SEG$ entry has no UET$ entries (Dictionary managed)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    tmp1 Varchar2(16) := Null ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        tmp1 := Null ;
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        If ( c1.type# = 9 ) Then
          tmp1 := ' (May Be Ok)' ;
        End If ;
        hout.put_line('SEG$ has no UET$ entry: TS#='||c1.TS#||' RFILE#='||
            c1.file#||' BLK#='||c1.block#||' TYPE#='||c1.type#||tmp1);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure SeglessUET
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select u.ts#, u.segfile#, u.segblock#, Count('x') cnt, Min(ext#) minext#
      From   seg$ s, uet$ u
      Where  s.ts#(+)    = u.ts#
      And    s.file#(+)  = u.segfile#
      And    s.block#(+) = u.segblock#
      And    s.ts# Is Null              /* no SEG$ entry */
      Group  By u.ts#, u.segfile#, u.segblock#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0009' ;
    ps1a Varchar2(65) := 'UET$ entry has no SEG$ entries (Dictionary managed)' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('UET$ has no SEG$ entry: TS#='||c1.TS#||' SegFILE#='||
            c1.segfile#||' SegBLK#='||c1.segblock#||' Count='||
            c1.cnt||' MinExt#='||c1.minext#);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadInd$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select o.obj# OBJ#, u.name OWNER, o.name NAME
      from   user$ u, obj$ o, ind$ i
      where  u.user# = o.owner#
      and    o.type# = 1                  /* INDEX */
      and    o.obj#  = i.obj#(+)
      and    i.obj# is null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0030' ;
    ps1a Varchar2(65) := 'OBJ$ INDEX entry has no IND$ entry' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('INDEX has no IND$ entry: Obj='||c1.obj#||' '||
            c1.owner||'.'||c1.name);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadTab$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj# OBJ#, u.name OWNER, o.name NAME
      From   user$ u, obj$ o, tab$ i
      Where  u.user# = o.owner#
      And    o.name != 'DR$DBO'
      And    o.type# = 2             /* TABLE */
      And    o.obj#  = i.obj#(+)
      And    i.obj#     Is Null
      And    o.linkname Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0031' ;
    ps1a Varchar2(65) := 'OBJ$ TABLE entry has no TAB$ entry' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('TABLE has no TAB$ entry: Obj='||c1.obj#||' '||
            c1.owner||'.'||c1.name);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadIcolDepCnt
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select i.obj# , nvl(i.spare1,i.intcols) expect, ic.cnt got
      from ind$ i,
      (select obj#, count(*) cnt from icoldep$ group by obj# ) ic
      where ic.obj#=i.obj#
      and ic.cnt!=nvl(i.spare1,i.intcols)
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0032' ;
    ps1a Varchar2(65) := 'ICOLDEP$ count!=IND$ expected num dependencies' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:5217913' ;
    aff1 Varchar2(80) := 
         'Affects: All Vers >= 9.2.0.4 <= 10.2.0.5' ;
    fix1 Varchar2(80) := 
         'Fixed  : 11.1.0.7' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ#='||c1.OBJ#||' '||ObjName(c1.obj#)||
            ' IND$ expects '||c1.expect||' ICOLDEP$ has '||c1.got);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure WarnIcolDep
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select adt.obj#,adt.icobj#, adt.intcol#,adt.name
      from
      ( select c.obj#, ic.obj# icobj#, c.intcol#, c.name
       from col$ c , icoldep$ ic
       where c.type#=121 /*index on ADT*/
        and c.obj#=ic.bo#
        and c.intcol#=ic.intcol#
      ) adt,
      (select c.obj#, c.intcol#, c.name , ic.obj# icobj#
        from col$ c , icoldep$ ic
        where bitand(c.property,33)=33        /* index on ADT attribute */
         and c.obj#=ic.bo#
         and c.intcol#=ic.intcol#
      ) adtattr
      where adt.obj#=adtattr.obj#             /* same table */
        and adt.icobj#=adtattr.icobj#         /* same index */
        and adt.intcol#+1 = adtattr.intcol#   /* likely same ADT/attr */
      order by 1,2
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0010' ;
    ps1a Varchar2(65) := 'ICOLDEP$ may reference ADT and its attributes' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:5217913' ;
    aff1 Varchar2(80) := 
         'Affects: All Vers >= 9.2.0.4 <= 10.2.0.5' ;
    fix1 Varchar2(80) := 
         'Fixed  : 11.1.0.7' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('Index OBJ#='||c1.ICOBJ#||' '||ObjName(c1.icobj#)||
            ' intcol#='||c1.intcol#||'='||c1.name);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OnlineRebuild$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj# OBJ#, u.name OWNER, o.name NAME,
             o.dataobj# O_ID, i.dataobj# I_ID
      From   user$ u, obj$ o, ind$ i
      Where  u.user#     = o.owner#
      And    o.type#     = 1             /* INDEX */
      And    o.obj#      = i.obj#
      And    o.dataobj# != i.dataobj#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0033' ;
    ps1a Varchar2(65) := 'OBJ$.DATAOBJ# != IND.DATAOBJ#' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.125149.1: ALTER INDEX .. REBUILD ONLINE can corrupt index' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(c1.owner||'.'||c1.name||' OBJ$.DATAOBJ#='||c1.o_id||
            'IND$.DATAOBJ#='||c1.i_id);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure DropForceType
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select u.name owner, o.name name , a.name attr
      From   user$ u, obj$ o, type$ t, attribute$ a, type$ att
      Where  u.user#                    = o.owner#
      And    o.oid$                     = t.toid
      And    o.type#                   != 10     -- must not be invalid
      And    Bitand(t.properties, 2048) = 0      -- not system-generated
      And    t.toid                     = a.toid
      And    t.version#                 = a.version#
      And    a.attr_toid                = att.toid(+)
      And    a.attr_version#            = att.version#(+)
      And    att.toid Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0034' ;
    ps1a Varchar2(65) := 'Bad ATTRIBUTE$.ATTR_TOID entries' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1584155' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8 and BELOW 10.1 Specifically: 8.1.7.4 9.2.0.2' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.5 9.2.0.3 10.1.0.2' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.1584155.8: DROP FORCE/RECREATE TYPE with DEPENDENCIES corrupts';
    not2 Varchar2(80) := 
         '                dictionary information' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line(c1.owner||'.'||c1.name||' ATTR_NAME='||c1.attr);
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure TrgAfterUpgrade
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select Count('x') cnt from trigger$
      where  sys_evts Is Null or nttrigcol Is Null
      Having Count('x') > 0
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0035' ;
    ps1a Varchar2(65) := 'TRIGGER$ has NULL entries - Count = ' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a||c1.cnt) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure FailedInitJVMRun
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select obj#, type#, name
      From   obj$
      Where  type#=0
      And    name!='_NEXT_OBJECT'
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0036' ;
    ps1a Varchar2(65) := 'Bad OBJ$ entry with TYPE#=0' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1365707' ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ$ OBJ#='||c1.OBJ#||' TYPE#=0 NAME='||c1.name);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure TypeReusedAfterDrop
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#, owner#, name
      From   obj$ o, view$ v
      Where  o.type#              = 4
      And    v.obj#               = o.obj#
      And    Bitand(v.property,1) = 0
      And    o.oid$ Is Not Null
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0037' ;
    ps1a Varchar2(65) := 'OBJ$.OID$ set for a VIEW' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1842429' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8 and BELOW 9.0.1' ;
    fix1 Varchar2(80) := 
         'Fixed  : 9.0.1.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.1842429.8: Dictionary corruption / ORA-600 [kkdodoid1] ' ;
    not2 Varchar2(80) := 
         '                possible after DROP TYPE' ;
    not3 Varchar2(80) := 
         '@ Support Only: Note.157540.1: Bug:1842429 / OERI [kkdodoid1] ' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          if (not3 Is Not Null) Then hout.put_line(not3); not3:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ$ OBJ#='||c1.OBJ#||' Owner='||Owner(c1.owner#)||
            ' NAME='||c1.name);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure Idgen1$TTS
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
     select increment$ from seq$ s , obj$ o
      where o.name='IDGEN1$' and owner#=0
        and s.obj#=o.obj#
        and increment$>50
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0011' ;
    ps1a Varchar2(65) := 'Sequence IDGEN1$ (INCREMENT_BY) too high' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1375026' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8 and BELOW 9.0 Specifically: 8.1.7.1' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.2 9.0.1.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.1375026.8: ORA-600 [13302] possible after a transportable' ;
    not2 Varchar2(80) := 
         '                tablespace has been plugged in ' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure DroppedFuncIdx
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select distinct u.name owner, o.name tab
      from   user$ u, obj$ o, col$ c
      where  o.type#                  = 2
      and    c.col#                   = 0
      and    Bitand(32768,c.property) = 32768
      and    o.obj#                   = c.obj#
      and    u.user#                  = o.owner#
      and    u.user#                 != 0
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0012' ;
    ps1a Varchar2(65) := 'Table with Dropped Func Index' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1805146' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=8.1 and BELOW 9.2 Specifically: 8.1.7.2 9.0.1.2' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.3 9.0.1.3 9.2.0.1' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.148740.1: ALERT: Export Of Table With Dropped Functional' ;
    not2 Varchar2(80) := 
         '               Index May Cause IMP-20 On Import ' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('Table='||c1.owner||'.'||c1.tab);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadOwner
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select obj#, type#, owner#, name
      From   obj$
      Where  owner# not in (Select user# From user$)
      And    type# != 10
    ;

    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0038' ;
    ps1a Varchar2(65) := 'OBJ$.OWNER# not in USER$' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1359472' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 9.0   Specifically: 8.1.7.1' ;
    fix1 Varchar2(80) := 
         'Fixed  : 8.1.7.2 9.0.1.0' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         '@Support Only: Note.333181.1: OBJ$.OWNER# not in USER$. Drop' ;
    not2 Varchar2(80) := 
         '               tablespace returns ORA-1549' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ$ OBJ#='||c1.OBJ#||' TYPE='||c1.type#||' NAME='||
            c1.name||' Owner#='||c1.OWNER#);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure UpgCheckc0801070
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select option#, Count('x')
      From   STMT_AUDIT_OPTION_MAP
      Where  option# = 229
      And    name    = 'ON COMMIT REFRESH'
      Group  By option#
      Having Count('x') > 0
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0013' ;
    ps1a Varchar2(65) := 'option# in STMT_AUDIT_OPTION_MAP(ON COMMIT REFRESH)' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:6636804' ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('-- Please run the following:') ;
        hout.put_line('SQL> update STMT_AUDIT_OPTION_MAP set option#=234') ;
        hout.put_line('     where name =''ON COMMIT REFRESH'' ;') ;
        hout.put_line('SQL> commit ;') ;
        Fatal:=Fatal+1;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadPublicObjects
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select obj#,name,type#
      From   obj$
      Where  owner#=1
      And    type# not in (5,10)
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0014' ;
    ps1a Varchar2(65) := 'Objects owned by PUBLIC' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:1762570' ;
    aff1 Varchar2(80) := 
         'Affects: Vers >=7' ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.1762570.8: It is possible to create objects OWNED by PUBLIC' ;
    not2 Varchar2(80) := 
         '                This may cause ORA-600[15261] / ORA-4050 / ORA-4043' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          if (not2 Is Not Null) Then hout.put_line(not2); not2:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ$ OBJ#='||c1.OBJ#||' TYPE='||c1.type#||
            ' NAME='||c1.name);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadSegFreelist
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select s.ts#, s.file#, s.block#, type#, s.lists, s.groups,
             bitand(l.property, 2048) bitp2048
      From   seg$ s, lob$ l
      Where  s.ts#      = l.ts#(+)
      And    s.file#    = l.file#(+)
      And    s.block#   = l.block#(+)
      And    ( s.lists  = 1 Or  s.groups            =    1 )
      -- And    bitand(nvl(l.property(+),0), 2048) != 2048
    ;
    -- OLD:
    --  Select ts#,file#,block#,type#,lists,groups
    --  From   seg$
    --  Where  lists=1 Or groups=1
    -- ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0015' ;
    ps1a Varchar2(65) := 'SEG$ bad LISTS/GROUPS (==1)' ;
    ps1b Varchar2(80) := 'May be Ok for LOBSEGMENT/SECUREFILE' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If ( c1.bitp2048 != 2048 ) Then
          If (ps1 Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              if ( nCatV > 1100000000 ) Then
                hout.put_line (ps1b) ;
              End If ;
              ps1:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line('Bad SEG$ lists/groups : TS#='||c1.TS#||' RFILE#='||
              c1.file#||' BLK#='||c1.block#||' TYPE#='||c1.type#||
              ' Lists='||c1.lists||' Groups='||c1.groups) ;
          Warn := Warn + 1 ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadCol#
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj# , Max(intcol#) maxi, Max(col#) maxc
      From   sys.col$ o
      Group  By o.obj#
      Having Max(intcol#)>1000 Or max(col#)>999
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0039' ;
    ps1a Varchar2(65) := 'COL$ (INTCOL#/COL#) too high' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2212987' ;
    aff1 Varchar2(80) := 
         'Affects: Vers BELOW 10.1 Specifically: 9.2.0.6' ;
    fix1 Varchar2(80) := 
         'Fixed  : 9.2.0.8 10.1.0.2' ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := 
         'Note.2212987.8: Dictionary corruption can occur '||
         'as function index allowed' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ#='||c1.obj#||' max(intcol#)'||c1.maxi||
            ' max(col#)='||c1.maxc);
        Fatal := Fatal + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
--------------------------------------------------------------------------------
--
  Procedure BadDepends
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.obj#          dobj        ,
             p.obj#          pobj        ,
             d.p_timestamp   p_timestamp ,
             p.stime         p_stime     ,
             o.type#         o_type      ,
             p.type#         p_type
      From   sys.obj$        o           ,
             sys.dependency$ d           ,
             sys.obj$        p
      Where  p_obj#   = p.obj# (+)
      And    d_obj#   = o.obj#
      And    o.status = 1                    /*dependent is valid*/
      And    o.subname is null                /*!Old TYPE version*/
      And    bitand(d.property, 1) = 1          /*Hard dependency*/
      And    p.status = 1                       /*parent is valid*/
      And    p.stime !=d.p_timestamp /*parent timestamp not match*/
      Order  By 2,1
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0016' ;
    ps1a Varchar2(65) := 'Dependency$ p_timestamp mismatch for VALID objects' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    to_chk Varchar2 (4) ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        If ( (c1.o_type = 5) and (c1.p_type = 29) ) Then
          to_chk := '[W]'  ;
        Else
          to_chk := '[E]' ;
        End If ;
        hout.put_line(to_chk||' - P_OBJ#='||c1.pobj||' D_OBJ#='||c1.dobj);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure CheckDual
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select dummy From dual
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0017' ;
    ps1a Varchar2(65) := 'DUAL has more than one row' ;
    ps1b Varchar2(80) := 'DUAL does not contain ''X''' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    n    Number       := 0 ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        n := n + 1 ;
        If ( n > 1 ) Then
          If (ps1a Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1a) ;
              ps1a:=null;
          End If;
           If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          Warn := Warn + 1 ;
        End If ;
        If ( Nvl(c1.dummy,'Z') != 'X' ) Then
          If (ps1b Is Not Null) Then
              CursorRun := TRUE ;
              hout.put_line (chr(10)||ps1||': '||ps1b) ;
              ps1b:=null;
          End If;
          Warn := Warn + 1 ;
        End If ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure ObjectNames
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
    select username, object_type,
           Substr(owner||'.'||object_name,1,62) Name
    from   dba_objects, dba_users
    where  object_name = username
    and   (owner=username Or owner='PUBLIC')
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0018' ;
    ps1a Varchar2(65) := 'OBJECT name clashes with SCHEMA name' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2894111' ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('Schema='||c1.username||' Object='||c1.name||' ('||
            c1.object_type||')');
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadCboHiLo
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select obj#,intcol#,lowval,hival from hist_head$ where lowval>hival
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0019' ;
    ps1a Varchar2(65) := 'HIST_HEAD$.LOWVAL > HIVAL' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ# '||c1.obj#||' INTCOL#='||c1.intcol#);
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure ChkIotTs
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select o.owner#, o.obj# , o.name , t.ts#, t.file#, t.block#
      From   sys.obj$ o, sys.tab$ t
      Where  Bitand(t.property,64) = 64 /* Marked as an IOT */
      And    ts#                  != 0
      And    o.obj#                = t.obj#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0020' ;
    ps1a Varchar2(65) := 'IOT Tab$ has TS#!=0' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ#='||c1.obj#||' ('||Owner(c1.owner#)||'.'||
            c1.name||') '||' TS#='||c1.ts#||' f='||c1.file#||' b='||c1.block#) ;
        Warn := Warn + 1 ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure NoSegmentIndex
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select i.obj#, i.dataobj#, i.ts#, i.file#, i.block#, i.bo#, s.type#
      from   seg$ s, ind$ i
      where  i.ts#                = s.ts#(+)
      and    i.file#              = s.file#(+)
      and    i.block#             = s.block#(+)
      and    Bitand(i.flags,4096) = 4096  /* Exclude NOSEGMENT index */
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKW-0021' ;
    ps1a Varchar2(65) := 'NOSEGMENT IND$ exists' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 
         'CORR/DIC HCHECK '||ps1 ; 
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If ( nF = 0) Then
        sFr := InitsFr ;
      End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        If (ps1 Is Not Null) Then
            CursorRun := TRUE ;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=null;
        End If;
         If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('NOSEGMENT IND$: OBJ='||c1.obj#||
            ' DOBJ='||c1.dataobj#||
            ' TS='||c1.TS#||
            ' RFILE/BLOCK='||c1.file#||' '||c1.block#||
            ' BO#='||c1.bo#||' SegType='||c1.type#);
        If (c1.type# Is Not Null) Then
          hout.put_line('^- PROBLEM: NOSEGMENT Index has a segment attached');
        End If ;
        Warn := Warn + 1 ;
        if (c1.TS#!=0 or c1.file#!=0 or c1.block#!=0) then
          hout.put_line('^- Index has ts#/file#/block# set') ;
        end if ;
        CheckIndPart (c1.obj#) ;
      End Loop ; 
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure BadNextObject
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select no.dataobj#, mx.maxobj#
      From   obj$ no , (select max(obj#) maxobj# from obj$) mx
      Where  no.type#=0 And no.name='_NEXT_OBJECT'
        and  mx.maxobj#>no.dataobj#
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0040' ;
    ps1a Varchar2(65) := 'OBJ$ _NEXT_OBJECT entry too low' ;
    bug1 Varchar2(80) := 'Ref    : Bug:10104492' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ$ _NEXT_OBJECT DATAOBJ#='||c1.dataOBJ#||
                ' MAX OBJ#='||c1.maxobj#);
        Fatal := Fatal + 1 ;
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure OrphanIndopt
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select i.obj#, i.bind#, Count(*) cnt
      From   sys.indop$ i
      Where  i.property != 4
      Group  By i.obj#, i.bind#
      Having Count(*) > 1
    ;
    nFr  Number ;
    ps1  Varchar2(10) := 'HCKE-0041' ;
    ps1a Varchar2(65) := 'Binding w/ multiple dictionary entries' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2161360' ;
    aff1 Varchar2(80) := 'Affects: Vers BELOW 10.1 - '||
         'Specifically: 9.2.0.1' ;
    fix1 Varchar2(80) :=
         'Fixed  : 10.1.0.2' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note:2161360.8 - DROP of OPERATOR corrupts dictionary';
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ# '||c1.obj#||' - BIND# '||c1.bind#||
                      '('||c1.cnt||')'
                     );
--
        Fatal := Fatal + 1 ;
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure UpgFlgBitTmp
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select s.user#, s.ts#, s.file#, s.block#
      From seg$ s
      Where Bitand(s.spare1,513) = 513
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKE-0042' ;
    ps1a Varchar2(80) := 'Segment Known != Temporary after upgrade' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug.2569255' ;
    aff1 Varchar2(80) := 'Affects: Vers >=9.0 and BELOW 10.1 - '||
         'Specifically: 9.2.0.2' ;
    fix1 Varchar2(80) := 
         'Fixed  : 9.2.0.3 10.1.0.2' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note:2569255.8 - OERI:KCBGTCR_5 dropping segment upgrade from 8i' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('USER#: '||c1.user#||' - TS# '||c1.ts#||' ('||c1.file#||
                      '/'||c1.block#||')'
        );
--
        Fatal := Fatal + 1 ;
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure RenCharView
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select u.name uname, o.name oname
      From   obj$ o, user$ u
      Where  o.type#= 4 
      And    o.spare1 = 0
      And    o.owner# = u.user#
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0022' ;
    ps1a Varchar2(80) := 'Renamed VIEW w/ CHAR columns' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:2909084' ;
    aff1 Varchar2(80) := 'Affects: Vers >=8 and BELOW 10.1 - '||
         'Specifically: 8.1.7.4 9.2.0.3' ;
    fix1 Varchar2(80) := 
         'Fixed: 8.1.7.5 9.2.0.4 10.1.0.2' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 2909084.8 - RENAME of a VIEW with CHAR column / wrong results' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('VIEW: '||c1.uname||'.'||c1.oname);
--
        Warn  := Warn  + 1 ; 
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure Upg9iTab$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select To_char(spare6), Count('x') nTot
      From   tab$
      Where  To_char(spare6) = '00-000-00'
      Group  By To_char(spare6)
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0023' ;
    ps1a Varchar2(80) := 'TAB$ contains corrupt data after upgrade to 9i' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:3091612' ;
    aff1 Varchar2(80) := 'Affects: Vers >=9.0 and BELOW 10.1 - '||
         'Specifically: 9.2.0.4' ;
    fix1 Varchar2(80) := 
         'Fixed: 9.2.0.5 10.1.0.2' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 3091612.8 - TAB$.SPARE6: corrupt data after upgrade to 9i' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('Total number of entries wrong: '||c1.nTot);
--
        Warn  := Warn  + 1 ; 
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure Upg9iTsInd
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select i.obj#, i.ts#, i.file#, i.block#, i.bo#
      From   ind$ i
      Where  ts# != 0
      And    bo# In (Select obj#
                     From   tab$
                     Where  Bitand(property, 12582912) != 0)
                     -- global           temporary table (0x00400000)
                     -- session-specific temporary table (0x00800000)
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0024' ;
    ps1a Varchar2(80) := 'Corrupt IND$ data for Global Temp Table Idx' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:3238525' ;
    aff1 Varchar2(80) := 'Affects: Vers >=9.2 and BELOW 10.1'||
         'Specifically: 9.2.0.3 9.2.0.5' ;
    fix1 Varchar2(80) := 
         'Fixed: 9.2.0.6 10.1.0.2' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 3238525.8 - Corrupt IND$ data after upgrade' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ#='||c1.obj#||
        ' TS#='||c1.ts#||' '||c1.file#||' '||c1.block#);
--
        Warn  := Warn  + 1 ; 
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure Upg10gInd$
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select To_char(spare6), Count('x') nTot
      From   ind$
      Where  To_char(spare6) = '00-000-00'
      Group  By To_char(spare6)
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0025' ;
    ps1a Varchar2(80) := 'IND$ contains corrupt data after upgrade to 10g' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:4134141' ;
    aff1 Varchar2(80) := 'Affects: Vers >=10.1 and BELOW 10.2'||
         'Specifically: 10.1.0.4' ;
    fix1 Varchar2(80) := 
         'Fixed: 10.1.0.5 10.2.0.1' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 842957.1 - EXPDP Fails With ORA-1801 During Schema Export' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('Total number of entries wrong: '||c1.nTot);
--
        Warn  := Warn  + 1 ; 
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure DroppedROTS
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select t.ts#, t.name, f.file#
      From   ts$ t, file$ f
      Where  t.ts# = f.ts# (+)
      And    t.online$ = 4
      And    f.file# Is Null
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKE-0043' ;
    ps1a Varchar2(80) :=
         'Dictionary inconsistency for dropped RO tablespace' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:3455402' ;
    aff1 Varchar2(80) := 'Affects: Vers BELOW 10.2 - '||
         'Specifically: 9.2.0.4 9.2.0.5' ;
    fix1 Varchar2(80) := 
         'Fixed: 9.2.0.6 10.1.0.4 10.2.0.1' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 3455402.8 - Corr: Concurrent DROP / ALTER TS READ ONLY' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('TS='||c1.ts#||'('||c1.name||')');
--
        Fatal := Fatal + 1 ;
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure ChrLenSmtcs
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      Select obj#, name, property, spare3, length
      From   col$
      Where  Bitand(property,8388608)!=0
      And    type#=23
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKW-0026' ;
    ps1a Varchar2(80) := 'NLS_LENGTH_SEMANTICS / RAW after upgrade' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:4638550' ;
    aff1 Varchar2(80) := 'Affects: Vers BELOW 11.1 - '||
         'Specifically: 10.2.0.2' ;
    fix1 Varchar2(80) := 
         'Fixed: 10.2.0.3 11.1.0.6' ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := 
         'Note: 4638550.8 - OERI[dmlsrvColLenChk_2:dty] on upgrade from 9.2' ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ#='||c1.obj#);
--
        Warn  := Warn  + 1 ; 
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure FilBlkZero
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    noTable EXCEPTION ;
    PRAGMA EXCEPTION_INIT(noTable, -942) ;
    Cursor sCur1 Is
      Select t_i.typ, t_i.ts#, t_i.file#, t_i.block#, t_i.obj#
      From
      (
        Select 'TABLE' typ, t.ts#, t.file#, t.block#, t.obj# from tab$ t
        Union All
        Select 'INDEX' typ, i.ts#, i.file#, i.block#, i.obj# from ind$ i
      ) t_i   ,
        ts$ t ,
        obj$ o
        Where t_i.ts#=t.ts#
        And   t.name not in ('SYSTEM','SYSAUX')
        And   t_i.file#  = 0
        And   t_i.block# = 0
        And   t_i.obj#   = o.obj#
        And   o.flags   != 2                  /* 0x02 -> Global Temp */
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKE-0044' ;
    ps1a Varchar2(80) := 'Object has zeroed file/block Information' ;
    bug1 Varchar2(80) := Null ;
    aff1 Varchar2(80) := Null ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
    def_obj    number   := 0 ;
    def_count  number   := 0 ;
    def_exists number   := 1 ;
    sqlstr  varchar2(80) := 'Select Count(''x'') From deferred_stg$' ;
    sqlstr1 varchar2(80) := 'Select obj# From deferred_stg$ Where obj# = :obj' ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      Begin
        Execute Immediate sqlstr Into def_count ;
        Exception
          When noTable Then
            def_exists := 0 ;
      End ;
      For c1 in sCur1 Loop
        If ( def_exists = 0 ) Then
          CursorRun:=TRUE;
          If (ps1 Is Not Null) Then
            CursorRun:=TRUE;
            hout.put_line (chr(10)||ps1||': '||ps1a) ;
            ps1:=Null;
          End If ;
          If ( V ) Then
            if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
            if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
            if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
            if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
            if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
            hout.put(chr(10)); V := FALSE ;
          End If ;
          hout.put_line(c1.typ||' - OBJ#='||c1.obj#||' TS#='||c1.ts#);
--
          Fatal := Fatal + 1 ; 
        Else
          Begin
            Execute Immediate sqlstr1 Into def_obj Using c1.obj# ;
          Exception
            When NO_DATA_FOUND Then
              If (ps1 Is Not Null) Then
                CursorRun:=TRUE;
                hout.put_line (chr(10)||ps1||': '||ps1a) ;
                ps1:=Null;
              End If ;
              If ( V ) Then
                if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null;
                End If;
                if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null;
                End If;
                if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null;
                End If;
                if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null;
                End If;
                if (not1 Is Not Null) Then hout.put_line(not1); not1:=null;
                End If;
                hout.put(chr(10)); V := FALSE ;
              End If ;
              hout.put_line(c1.typ||' - OBJ#='||c1.obj#||' TS#='||c1.ts#);
--
              Fatal := Fatal + 1 ;
          End ;
        End If ;
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
  Procedure DbmsSchemaCopy
           (nF      In Number  Default 0,
            VerChk  In Number  Default 5,
            Verbose In Boolean Default FALSE)
  Is
    Cursor sCur1 Is
      select o.obj#, u.name owner, o.name object
      from   obj$ o, user$ u
      where  o.owner# = u.user#
      and    o.type# in (4,5,6,7,8,9,11)
      and    o.subname='CLONE_USE'
    ;
    nFr  Number ;
    ps1  Varchar2(80) := 'HCKE-0045' ;
    ps1a Varchar2(80) := '"DBMS_SCHEMA_COPY" - Failed Execution' ;
    bug1 Varchar2(80) := 
         'Ref    : Bug:13383874' ;
    aff1 Varchar2(80) := 'Affects: 10gR2' ||
         'Specifically: (unresolved: 33)' ;
    fix1 Varchar2(80) := Null ;
    tag1 Varchar2(80) := 'CORR/DIC HCHECK '||ps1 ;
    not1 Varchar2(80) := Null ;
    CursorRun Boolean := FALSE ; V Boolean := Verbose ;
--
    Begin
      If (nF = 0) Then sFr := InitsFr ; End If ;
      nFr := hcheck.CatV2nCatV ( sFr(nF), VerChk );
      ChecknCatVnFR (nCatV, nFR, bRun) ;
      If ( bRun = FALSE ) Then return ; End If ;
      For c1 in sCur1 Loop
        CursorRun:=TRUE;
        hout.put_line (chr(10)||ps1||': '||ps1a) ;
        If ( V ) Then
          if (bug1 Is Not Null) Then hout.put_line(bug1); bug1:=null; End If;
          if (aff1 Is Not Null) Then hout.put_line(aff1); aff1:=null; End If;
          if (fix1 Is Not Null) Then hout.put_line(fix1); fix1:=null; End If;
          if (tag1 Is Not Null) Then hout.put_line(tag1); tag1:=null; End If;
          if (not1 Is Not Null) Then hout.put_line(not1); not1:=null; End If;
          hout.put(chr(10)); V := FALSE ;
        End If ;
        hout.put_line('OBJ#='||c1.obj#||' - '||c1.owner||'.'||c1.object);
--
        Fatal := Fatal + 1 ;
--
      End Loop ;
      If ( CursorRun ) Then hout.put(chr(10)) ; End If ;
    End;
--
-- Main
--
  Procedure Full (Verbose In Boolean Default FALSE,
                  RunAll  In Boolean Default FALSE,
                  VerChk  In Number  Default 5) Is
    FnIdx       Number := 0 ;
    nvc         Number ;
    stmt        Varchar2(80) := Null ;
    sV          Varchar2 (6) := 'FALSE' ;
  Begin
    Fatal  := 0 ;                    /* Number Of Fatal Errors */
    Warn   := 0 ;                    /* Number Of Warnings     */
--
-- List Of Procedure Names
--
    sFn (1) := 'SynLastDDLTim'             ; /*  1 */
    sFn (2) := 'LobNotInObj'               ; /*  2 */
    sFn (3) := 'MissingOIDOnObjCol'        ; /*  3 */
    sFn (4) := 'SourceNotInObj'            ; /*  4 */
    sFn (5) := 'IndIndparMismatch'         ; /*  5 */
    sFn (6) := 'InvCorrAudit'              ; /*  6 */
    sFn (7) := 'OversizedFiles'            ; /*  7 */
    sFn (8) := 'TinyFiles'                 ; /*  8 */
    sFn (9) := 'PoorDefaultStorage'        ; /*  9 */
    sFn(10) := 'PoorStorage'               ; /* 10 */
    sFn(11) := 'MissTabSubPart'            ; /* 11 */
    sFn(12) := 'PartSubPartMismatch'       ; /* 12 */
    sFn(13) := 'TabPartCountMismatch'      ; /* 13 */
    sFn(14) := 'OrphanedTabComPart'        ; /* 14 */
    sFn(15) := 'ZeroTabSubPart'            ; /* 15 */
    sFn(16) := 'MissingSum$'               ; /* 16 */
    sFn(17) := 'MissingDir$'               ; /* 17 */
    sFn(18) := 'DuplicateDataobj'          ; /* 18 */
    sFn(19) := 'ObjSynMissing'             ; /* 19 */
    sFn(20) := 'ObjSeqMissing'             ; /* 20 */
    sFn(21) := 'OrphanedUndo'              ; /* 22 */
    sFn(22) := 'OrphanedIndex'             ; /* 21 */
    sFn(23) := 'OrphanedIndexPartition'    ; /* 23 */
    sFn(24) := 'OrphanedIndexSubPartition' ; /* 24 */
    sFn(25) := 'OrphanedTable'             ; /* 25 */
    sFn(26) := 'OrphanedTablePartition'    ; /* 26 */
    sFn(27) := 'OrphanedTableSubPartition' ; /* 27 */
    sFn(28) := 'MissingPartCol'            ; /* 28 */
    sFn(29) := 'OrphanedSeg$'              ; /* 29 */
    sFn(30) := 'OrphanedIndPartObj#'       ; /* 30 */
    sFn(31) := 'DuplicateBlockUse'         ; /* 31 */
    sFn(32) := 'HighObjectIds'             ; /* 32 */
    sFn(33) := 'PQsequence'                ; /* 33 */
    sFn(34) := 'TruncatedCluster'          ; /* 34 */
    sFn(35) := 'FetUet'                    ; /* 35 */
    sFn(36) := 'Uet0Check'                 ; /* 36 */
    sFn(37) := 'ExtentlessSeg'             ; /* 37 */
    sFn(38) := 'SeglessUET'                ; /* 38 */
    sFn(39) := 'BadInd$'                   ; /* 39 */
    sFn(40) := 'BadTab$'                   ; /* 40 */
    sFn(41) := 'BadIcolDepCnt'             ; /* 41 */
    sFn(42) := 'WarnIcolDep'               ; /* 42 */
    sFn(43) := 'OnlineRebuild$'            ; /* 43 */
    sFn(44) := 'DropForceType'             ; /* 44 */
    sFn(45) := 'TrgAfterUpgrade'           ; /* 45 */
    sFn(46) := 'FailedInitJVMRun'          ; /* 46 */
    sFn(47) := 'TypeReusedAfterDrop'       ; /* 47 */
    sFn(48) := 'Idgen1$TTS'                ; /* 48 */
    sFn(49) := 'DroppedFuncIdx'            ; /* 49 */
    sFn(50) := 'BadOwner'                  ; /* 50 */
    sFn(51) := 'UpgCheckc0801070'          ; /* 51 */
    sFn(52) := 'BadPublicObjects'          ; /* 52 */
    sFn(53) := 'BadSegFreelist'            ; /* 53 */
    sFn(54) := 'BadCol#'                   ; /* 54 */
    sFn(55) := 'BadDepends'                ; /* 55 */
    sFn(56) := 'CheckDual'                 ; /* 56 */
    sFn(57) := 'ObjectNames'               ; /* 57 */
    sFn(58) := 'BadCboHiLo'                ; /* 58 */
    sFn(59) := 'ChkIotTs'                  ; /* 59 */
    sFn(60) := 'NoSegmentIndex'            ; /* 60 */
    sFn(61) := 'BadNextObject'             ; /* 61 */
    sFn(62) := 'OrphanIndopt'              ; /* 62 */
    sFn(63) := 'UpgFlgBitTmp'              ; /* 63 */
    sFn(64) := 'RenCharView'               ; /* 64 */
    sFn(65) := 'Upg9iTab$'                 ; /* 65 */
    sFn(66) := 'Upg9iTsInd'                ; /* 66 */
    sFn(67) := 'Upg10gInd$'                ; /* 67 */
    sFn(68) := 'DroppedROTS'               ; /* 68 */
    sFn(69) := 'ChrLenSmtcs'               ; /* 69 */
    sFn(70) := 'FilBlkZero'                ; /* 70 */
    sFn(71) := 'DbmsSchemaCopy'            ; /* 71 */
--
    sFr    := InitsFr ;
--
--  number of fields in the release to check against
--  can never be > 5 or < 1
--
    nvc := VerChk ;

    If ( VerChk > 5 Or VerChk < 1 ) Then
      nvc := 5 ; 
    End If ;
--
-- Get Catalog Version (Both String and Number)
--
    If ( RunAll ) Then
      CatV := '0.0.0.0.0' ;
      nCatV := 0 ;
    Else
      Select version Into CatV From dba_registry Where comp_id='CATALOG' ;
      nCatV := hcheck.CatV2nCatV ( CatV, nvc ) ;
    End If ;
    hout.put_line('H.Check Version '||Ver);
    hout.put_line('---------------------------------------') ;
    hout.put_line('Catalog Version '||Lpad(CatV,10,' ')||' '||
        Lpad( '('||To_char(nCatV)||')', 12, ' ')
    ) ;
    hout.put_line('---------------------------------------') ;
--
     If ( Verbose ) Then
      hout.put_line('Running in Verbose mode ...') ;
      sV := 'TRUE' ;
    End If ;
--
    hout.put(chr(10));
    hout.put_line('                                   Catalog   '||
        '    Fixed           ') ;
    hout.put_line('Procedure Name                     Version   '||
        ' Vs Release      Run') ;
    hout.put_line('------------------------------ ... ----------'||
        ' -- ----------   ---') ;
--
-- Call All Defined Procedures
--
    For FnIdx in 1..nFunc Loop
      stmt := 'Begin hcheck.'||
              sFn(FnIdx)||' '||'('||
                FnIdx||', '||
                nvc||', '||
                sV||
              ')'||' ; End ;' ;

      hout.put(Rpad('.- '||sFn(FnIdx), 30, ' ')||' ... ') ;
      Execute Immediate stmt ;
    End Loop ;
--
    hout.put_line(chr(10)||'Found '||Fatal||' potential problem(s) and '||
                  warn||' warning(s)');
    hout.new_line;

    If (Fatal>0 or Warn>0) Then
      hout.put_line('Contact Oracle Support with the output');
      hout.put_line('to check if the above needs attention or not');
    End If;
  End ; 
End hcheck ;
/

set serveroutput on size 1000000
exec hcheck.Full ;

