     /* ===================================================================== */
     /*  iRPGUnit - Update RPGUNIT library.                                   */
     /* ===================================================================== */
     /*  Copyright (c) 2013-2020 iRPGUnit Project Team                        */
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
     /*       >>PARM<< REXSRCFILE(*LIBL/QBUILD);                              */
     /*       >>PARM<< REXSRCMBR(UPDLIBCPP);                                  */
     /*       >>PARM<< HLPPNLGRP(*LIBL/UPDLIBHLP);                            */
     /*       >>PARM<< HLPID(UPDLIB);                                         */
     /*     >>END-COMPILE<<                                                   */
     /*     >>EXECUTE<<                                                       */
     /*   >>END-PRE-COMPILER<<                                                */
     /* ===================================================================== */
             CMD        PROMPT('iRPGUnit - Update Library')

             PARM       KWD(LIB)                             +
                        TYPE(*NAME)                          +
                        MIN(1)                               +
                        PROMPT('Library')

