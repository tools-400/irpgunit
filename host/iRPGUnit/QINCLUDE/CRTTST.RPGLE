      /if not defined (IRPGUNIT_RUCRTTST)
      /define IRPGUNIT_RUCRTTST
      // ==========================================================================
      //  iRPGUnit - Implementation of RUCRTTST command.
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

     D getDltModCmd...
     D                 pr                        like(Cmd_t)
     D                                     extproc('CRTTST_+
     D                                     getDltModCmd+
     D                                     ')
     D  testPgm                            const likeds(Object_t)

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

     D serializeObjectArray...
     D                 pr                        like(SerializedArray_t)
     D                                     extproc('CRTTST_+
     D                                     serializeObjectArray+
     D                                     ')
     D  headToken                    10a   const
     D  array                              const likeds(ObjectArray_t)

     D serializeObjectName...
     D                 pr            21a   varying
     D                                     extproc('CRTTST_+
     D                                     serializeObjectName+
     D                                     ')
     D  object                             const likeds(Object_t)

     D serializeOptions...
     D                 pr                        like(SerializedOptions_t)
     D                                     extproc('CRTTST_+
     D                                     serializeOptions+
     D                                     ')
     D headToken                     10a   const
     D options                             const likeds(Options_t)

     D serializeString...
     D                 pr                        like(SerializedString_t)
     D                                     extproc('CRTTST_+
     D                                     serializeString+
     D                                     ')
     D headToken                     10a   const
     D text                        5000a   const varying options(*varsize)

     D serializeValue...
     D                 pr                        like(SerializedString_t)
     D                                     extproc('CRTTST_+
     D                                     serializeValue+
     D                                     ')
     D headToken                     10a   const
     D value                               const like(String_t)

     D addTestCaseModule...
     D                 pr                        likeds(ObjectArray_t)
     D                                     extproc('CRTTST_+
     D                                     addTestCaseModule+
     D                                     ')
     D  modules                            const likeds(ObjectArray_t)
     D  testCase                           const likeds(Object_t)

      /endif
