**free
// ==========================================================================
//  iRPGUnit - Create Cobol Unit Test Suite CPP.
// ==========================================================================
//  Copyright (c) 2013-2019 iRPGUnit Project Team
//  All rights reserved. This program and the accompanying materials
//  are made available under the terms of the Common Public License v1.0
//  which accompanies this distribution, and is available at
//  http://www.eclipse.org/legal/cpl-v10.html
// ==========================================================================
// >>PRE-COMPILER<<
//   >>CRTCMD<<  CRTRPGMOD MODULE(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
//   >>IMPORTANT<<
//     >>PARM<<  OPTION(*EVENTF);
//     >>PARM<<  DBGVIEW(*LIST);
//   >>END-IMPORTANT<<
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt main(crtCbl);
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,CRTCBL


//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,CRTTST
/include qinclude,PGMMSG
/include qinclude,TEMPLATES
/include qinclude,TESTUTILS


//----------------------------------------------------------------------
//   MAIN PROGRAM
//----------------------------------------------------------------------

dcl-proc crtCbl;
  dcl-pi *n;
    testPgm      likeds(Object_t) const;
    srcFile      likeds(Object_t) const;
    srcMbr       like(SrcMbr_t.mbr) const;
    text         like(Text_t) const;
    cOption      likeds(Options_t) const;
    dbgView      like(DbgView_t) const;
    bndSrvPgm    likeds(ObjectArray_t) const;
    bndDir       likeds(ObjectArray_t) const;
    bOption      likeds(Options_t) const;
    define       likeds(defines_t) const;
    dltSplf      like(yesNo_t) const;
    actGrp       like(ActivationGroup_t) const;
    bModules     likeds(ObjectArray_t) const;
    pOption      likeds(Options_t) const;
    compileOpt   like(CompileOpt_t) const;
    targetRls    like(TargetRelease_t) const;
  end-pi;

  dcl-s srcMbrRslv like(srcMbr);
  dcl-s srcType char(10);

  if (srcMbr = '*TSTPGM');
    srcMbrRslv = testPgm.nm;
  else;
    srcMbrRslv = srcMbr;
  endif;

  monitor;
    srcType = getMemberType( srcFile.nm : srcFile.lib : srcMbrRslv );
  on-error;
    sndEscapeMsgAboveCtlBdy( 'Could not retrieve source type of member '
                           + %trim(srcMbrRslv)
                           + ' of file '
                           + %trim(srcFile.lib) + '/' + %trim(srcFile.nm)
                           + '.' );
  endmon;

  if (srcType <> MBR_CBLLE and srcType <> MBR_SQLCBLLE );
    sndEscapeMsgAboveCtlBdy( 'Source type ' + %trim(srcType)
                           + ' is not supported by command RUCRTCBL' );
  endif;

  crtTst( testPgm : srcFile : srcMbrRslv : text : cOption : dbgView
         : bndSrvPgm : bndDir : bOption : define : dltSplf : actGrp
         : bModules : '*N' : pOption : compileOpt : targetRls);

  *inlr = *on;

end-proc;
