      /if not defined (IRPGUNIT_CRTTST)
      /define IRPGUNIT_CRTTST
      // ==========================================================================
      //  iRPGUnit - Implementation of RUCRT* commands.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

       //----------------------------------------------------------------------
       //   PUBLIC PROTOTYPES
       //----------------------------------------------------------------------

     D crtTst...
     D                 pr
     D                                     extproc('CRTTST_+
     D                                     crtTst+
     D                                     ')
     D  testPgm                            const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  text                               const like(Text_t)
     D  cOption                            const likeds(Options_t)
     D  dbgView                            const like(DbgView_t)
     D  bndSrvPgm                          const likeds(ObjectArray_t)
     D  bndDir                             const likeds(ObjectArray_t)
     D  bOption                            const likeds(Options_t)
     D  dltSplf                            const like(yesNo_t)
     D  actGrp                             const like(ActivationGroup_t)
     D  bModules                           const likeds(ObjectArray_t)
     D  pRpgPpOpt                          const like(RpgPpOpt_t)
     D  pOption                            const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

     D serializeObjectName...
     D                 pr            21a   varying
     D                                     extproc('CRTTST_+
     D                                     serializeObjectName+
     D                                     ')
     D  object                             const likeds(Object_t)

     D getCrtRpgModCmd...
     D                 pr                        like(Cmd_t)
     D                                     extproc('CRTTST_+
     D                                     getCrtRpgModCmd+
     D                                     ')
     D  pgm                                const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  cOptions                           const likeds(Options_t)
     D  dbgView                      10a   const
     D  pRpgPpOpt                          const like(RpgPpOpt_t)
     D  pOptions                           const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

     D getCrtCblModCmd...
     D                 pr                        like(Cmd_t)
     D                                     extproc('CRTTST_+
     D                                     getCrtCblModCmd+
     D                                     ')
     D  pgm                                const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  cOptions                           const likeds(Options_t)
     D  dbgView                      10a   const
     D  pOptions                           const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

     D getCrtSrvPgmCmd...
     D                 pr                        like(Cmd_t)
     D                                     extproc('CRTTST_+
     D                                     getCrtSrvPgmCmd+
     D                                     ')
     D  pgm                                const likeds(Object_t)
     D  bndSrvPgm                          const likeds(ObjectArray_t)
     D  bndDir                             const likeds(ObjectArray_t)
     D  module                             const likeds(ObjectArray_t)
     D  options                            const likeds(Options_t)
     D  export                       10a   const
     D  actGrp                             const like(ActivationGroup_t)
     D  text                               const like(Text_t )

       //----------------------------------------------------------------------
       //   PRIVATE PROTOTYPES
       //----------------------------------------------------------------------

     d formatCommand...
     d                 pr                  like(Cmd_t)
     D                                     extproc('+
     D                                     formatCommand+
     D                                     ')
     d  cmd                                const like(Cmd_t)

     D getCreatedModulesFromJobLog...
     D                 pr                  likeds(ObjectArray_t)
     D                                     extproc('+
     D                                     getCreatedModulesFromJobLog+
     D                                     ')
     D  crtMsgId                      7a   const
     D  timeLimit                      z   const

     D addModules...
     D                 pr
     D                                     extproc('+
     D                                     addModules+
     D                                     ')
     D  modules                                  likeds(ObjectArray_t)
     D  items                                    likeds(ObjectArray_t)

     D addModule...
     D                 pr
     D                                     extproc('+
     D                                     addModule+
     D                                     ')
     D  modules                                  likeds(ObjectArray_t)
     D  module                             const likeds(Object_t)
     D  isFirstMod                     n   const options(*nopass)

     D resolveLibraries...
     D                 pr                  likeds(ObjectArray_t)
     D                                     extproc('+
     D                                     resolveLibraries+
     D                                     ')
     D  modules                            const likeds(ObjectArray_t)

     D crtCblMod...
     D                 pr
     D                                     extproc('+
     D                                     crtCblMod+
     D                                     ')
     D  testPgm                            const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  cOption                            const likeds(Options_t)
     D  dbgView                            const like(DbgView_t)
     D  pOption                            const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

     D crtSrvPgm...
     D                 pr                  likeds(Object_t)
     D                                     extproc('+
     D                                     crtSrvPgm+
     D                                     ')
     D  testPgm                            const likeds(Object_t)
     D  bndSrvPgm                          const likeds(ObjectArray_t)
     D  bndDir                             const likeds(ObjectArray_t)
     D  module                             const likeds(ObjectArray_t)
     D  bOption                            const likeds(Options_t)
     D  actGrp                             const like(ActivationGroup_t)
     D  text                               const like(Text_t)

     D deleteModulesAndSpooledFiles...
     D                 pr
     D                                     extproc('+
     D                                     deleteModulesAndSpooledFiles+
     D                                     ')
     D  dltSplf                        n   const
     D  startTime                      z   const
     D  modules                            const likeds(ObjectArray_t)

     D getDltModCmd...
     D                 pr                        like(Cmd_t)
     D                                     extproc('+
     D                                     getDltModCmd+
     D                                     ')
     D  testPgm                            const likeds(Object_t)

     D serializeObjectArray...
     D                 pr                        like(SerializedArray_t)
     D                                     extproc('+
     D                                     serializeObjectArray+
     D                                     ')
     D  headToken                    10a   const
     D  array                              const likeds(ObjectArray_t)

     D serializeOptions...
     D                 pr                        like(SerializedOptions_t)
     D                                     extproc('+
     D                                     serializeOptions+
     D                                     ')
     D headToken                     10a   const
     D options                             const likeds(Options_t)

     D serializeString...
     D                 pr                        like(SerializedString_t)
     D                                     extproc('+
     D                                     serializeString+
     D                                     ')
     D headToken                     10a   const
     D text                        5000a   const varying options(*varsize)

     D serializeValue...
     D                 pr                        like(SerializedString_t)
     D                                     extproc('+
     D                                     serializeValue+
     D                                     ')
     D headToken                     10a   const
     D value                               const like(String_t)

     D addTestCaseModule...
     D                 pr                        likeds(ObjectArray_t)
     D                                     extproc('+
     D                                     addTestCaseModule+
     D                                     ')
     D  modules                            const likeds(ObjectArray_t)
     D  testCase                           const likeds(Object_t)

      /endif
