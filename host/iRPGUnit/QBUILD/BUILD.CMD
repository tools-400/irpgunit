     /* ===================================================================== */
     /*  iRPGUnit - Install Utility. (Command interface of A_INSTALL program) */
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
     /*       >>PARM<< PGM(&LI/A_INSTALL);                                    */
     /*       >>PARM<< HLPPNLGRP(&LI/BUILDHLP);                               */
     /*       >>PARM<< HLPID(BUILD);                                          */
     /*     >>END-COMPILE<<                                                   */
     /*     >>EXECUTE<<                                                       */
     /*   >>END-PRE-COMPILER<<                                                */
     /* ===================================================================== */
             CMD        PROMPT('iRPGUnit - Install Utility')

             PARM       KWD(PRDLIB)                          +
                        TYPE(*NAME)                          +
                        LEN(10)                              +
                        MIN(1)                               +
                        PROMPT('Product library')

             PARM       KWD(OPTION)                          +
                        TYPE(*CHAR)                          +
                        LEN(10)                              +
                        MIN(0)                               +
                        DFT(*INSTALL)                        +
                        RSTD(*YES)                           +
                        SPCVAL((*INSTALL  INSTALL)           +
                               (*CMPMODS  CMPMODS)           +
                               (*DLTMODS  DLTMODS))          +
                        PROMPT('Option')

             PARM       KWD(TGTRLS)                          +
                        TYPE(*CHAR)                          +
                        LEN(10)                              +
                        MIN(0)                               +
                        DFT(*CURRENT)                        +
                        PROMPT('Target release')

