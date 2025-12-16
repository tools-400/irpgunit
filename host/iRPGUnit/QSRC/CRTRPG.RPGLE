**free
// ==========================================================================
//  iRPGUnit - Create RPG Unit Test Suite CPP.
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
//   >>CMD<<     STRREXPRC SRCMBR(A_INSTALL) SRCFILE(&LI/QBUILD) +
//               PARM('CMPMOD &LI LIST');
//   >>EXECUTE<<
// >>END-PRE-COMPILER<<
// ==========================================================================

ctl-opt main(crtRpg);
/include qinclude,H_SPEC
/include qinclude,COPYRIGHT

//----------------------------------------------------------------------
//   Exported Procedures
//----------------------------------------------------------------------

/include qinclude,CRTRPG


//----------------------------------------------------------------------
//   IMPORTS
//----------------------------------------------------------------------

/include qinclude,CRTTST
/include qinclude,PGMMSG
/include qinclude,TEMPLATES
/include qinclude,TESTUTILS
/include qinclude,STRING


//----------------------------------------------------------------------
//   MAIN PROGRAM
//----------------------------------------------------------------------

dcl-proc crtRpg;
  dcl-pi *n;
    testPgm      likeds(Object_t) const;
    srcFile      likeds(Object_t) const;
    srcMbr       like(SrcMbr_t.mbr) const;
    srcStmf      like(ifsStmf_t) const;
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
    pRpgPpOpt    like(RpgPpOpt_t) const;
    pOption      likeds(Options_t) const;
    compileOpt   like(CompileOpt_t) const;
    targetRls    like(TargetRelease_t) const;
    incDir       likeds(incDir_t) const;
    tgtCcsid     like(tgtCcsid_t) const;
  end-pi;

  crtTst(testPgm: srcFile: srcMbr: srcStmf : text: cOption: dbgView
         : bndSrvPgm: bndDir: bOption: define: dltSplf: actGrp
         : bModules: pRpgPpOpt: pOption: compileOpt: targetRls: incDir: tgtCcsid);

  *inlr = *on;

end-proc;
