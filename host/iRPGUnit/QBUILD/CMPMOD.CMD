     /* ===================================================================== */
     /*  iRPGUnit - Compile Module.                                           */
     /* ===================================================================== */
     /*  Copyright (c) 2013-2019 iRPGUnit Project Team                        */
     /*  All rights reserved. This program and the accompanying materials     */
     /*  are made available under the terms of the Common Public License v1.0 */
     /*  which accompanies this distribution, and is available at             */
     /*  http://www.eclipse.org/legal/cpl-v10.html                            */
     /* ===================================================================== */
     /*   >>PRE-COMPILER<<                                                    */
     /*     >>CRTCMD<<  CRTCMD        CMD(&LI/&OB) +                          */
     /*                               SRCFILE(&SL/&SF) SRCMBR(&SM);           */
     /*     >>COMPILE<<                                                       */
     /*       >>PARM<< PGM(*REXX);                                            */
     /*       >>PARM<< REXSRCFILE(&LI/QBUILD);                                */
     /*       >>PARM<< REXSRCMBR(CMPMODCPP);                                  */
     /*       >>PARM<< HLPPNLGRP(&LI/CMPMODHLP);                              */
     /*       >>PARM<< HLPID(CMPMOD);                                         */
     /*     >>END-COMPILE<<                                                   */
     /*     >>EXECUTE<<                                                       */
     /*   >>END-PRE-COMPILER<<                                                */
     /* ===================================================================== */
             CMD        PROMPT('iRPGUnit - Compile Module')

             PARM       KWD(MODULE)                          +
                        TYPE(MODULE)                         +
                        MIN(1)                               +
                        PROMPT('Module')

             PARM       KWD(SRCFILE)                         +
                        TYPE(SRCFILE)                        +
                        MIN(1)                               +
                        PROMPT('Source file')

             PARM       KWD(SRCMBR)                          +
                        TYPE(*NAME)                          +
                        LEN(10)                              +
                        MIN(0)                               +
                        DFT(*MODULE)                         +
                        SPCVAL(*MODULE)                      +
                        PROMPT('Source member')

             PARM       KWD(DBGVIEW)                         +
                        TYPE(*CHAR)                          +
                        LEN(10)                              +
                        MIN(0)                               +
                        DFT(*NONE)                           +
                        SPCVAL((*STMT)                       +
                               (*SOURCE)                     +
                               (*LIST)                       +
                               (*COPY)                       +
                               (*ALL)                        +
                               (*NONE))                      +
                        PROMPT('Debug view')

             PARM       KWD(TGTRLS)                          +
                        TYPE(*CHAR)                          +
                        LEN(6)                               +
                        MIN(0)                               +
                        DFT(V7R3M0)                          +
                        SPCVAL((*CURRENT *C)                 +
                               (*PRV     *P))                +
                        PROMPT('Target release')

             PARM       KWD(DEFINE)                          +
                        TYPE(*CHAR)                          +
                        LEN(50)                              +
                        MIN(0)                               +
                        MAX(32)                              +
                        DFT(*NONE)                           +
                        SPCVAL((*NONE    *N))                 +
                        PROMPT('Define condition names')

MODULE:      QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) MIN(1) +
                          PROMPT('Library')

SRCFILE:     QUAL       TYPE(*NAME) LEN(10) MIN(1)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) +
                          SPCVAL((*LIBL)) +
                          PROMPT('Library')

