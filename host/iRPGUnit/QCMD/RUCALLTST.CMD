     /* ===================================================================== */
     /*  iRPGUnit - Execute Test Suite.                                       */
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
     /*     >>IMPORTANT<<                                                     */
     /*       >>PARM<< PGM(*LIBL/RUCALLTST);                                  */
     /*       >>PARM<< VLDCKR(*LIBL/RUCALLTSTV);                              */
     /*       >>PARM<< HLPPNLGRP(*LIBL/RUCALLTST);                            */
     /*       >>PARM<< HLPID(RUCALLTST);                                      */
     /*     >>END-IMPORTANT<<                                                 */
     /*     >>EXECUTE<<                                                       */
     /*   >>END-PRE-COMPILER<<                                                */
     /* ===================================================================== */
             CMD        PROMPT('iRPGUnit - Execute Test Suite')

             PARM       KWD(TSTPGM)                          +
                        TYPE(OBJ)                            +
                        MIN(1)                               +
                        PROMPT('Test program')

             PARM       KWD(TSTPRC)                          +
                        TYPE(*CHAR)                          +
                        MIN(0)                               +
                        MAX(250)                             +
                        LEN(256)                             +
                        VARY(*YES *INT2)                     +
                        DFT(*ALL)                            +
                        SNGVAL(*ALL)                         +
                        CASE(*MIXED)                         +
                        PROMPT('Test procedure')

             PARM       KWD(ORDER)                           +
                        TYPE(*CHAR)                          +
                        LEN(10)                              +
                        RSTD(*YES)                           +
                        DFT(*API)                            +
                        VALUES(*API                          +
                               *REVERSE)                     +
                        PROMPT('Run order')

             PARM       KWD(DETAIL)                          +
                        TYPE(*CHAR)                          +
                        LEN(10)                              +
                        RSTD(*YES)                           +
                        DFT(*BASIC)                          +
                        VALUES(*BASIC                        +
                               *ALL)                         +
                        PROMPT('Report detail')

             PARM       KWD(OUTPUT)                          +
                        TYPE(*CHAR)                          +
                        LEN(10)                              +
                        RSTD(*YES)                           +
                        DFT(*ALLWAYS)                        +
                        VALUES(*ALLWAYS                      +
                               *ERROR                        +
                               *NONE)                        +
                        PROMPT('Create report')

             PARM       KWD(LIBL)                            +
                        TYPE(*NAME)                          +
                        MIN(0)                               +
                        MAX(250)                             +
                        DFT(*CURRENT)                        +
                        SNGVAL((*CURRENT)                    +
                               ( *JOBD  ))                   +
                        PROMPT('Libraries for unit test')

             PARM       KWD(JOBD)                            +
                        TYPE(JOBD)                           +
                        MIN(0)                               +
                        PMTCTL(P_JOBD)                       +
                        SNGVAL(*DFT)                         +
                        DFT(*DFT)                            +
                        PROMPT('Job description')

             PARM       KWD(RCLRSC)                          +
                        TYPE(*CHAR)                          +
                        LEN(10)                              +
                        RSTD(*YES)                           +
                        DFT(*NO)                             +
                        VALUES(*NO                           +
                               *ALWAYS                       +
                               *ONCE   )                     +
                        PROMPT('Reclaim resources')

             PARM       KWD(XMLSTMF)                         +
                        TYPE(*CHAR)                          +
                        LEN(1024)                            +
                        VARY(*YES *INT2)                     +
                        CASE(*MIXED)                         +
                        DFT(*NONE)                           +
                        SPCVAL((*NONE ''))                   +
                        PROMPT('XML stream file')

 OBJ:        QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL)       +
                        SPCVAL((*LIBL))                      +
                        PROMPT('Library')

 JOBD:       QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL)       +
                        SPCVAL(*LIBL)                        +
                        PROMPT('Library')

 P_JOBD:     PMTCTL     CTL(LIBL)                            +
                        COND((*EQ *JOBD))                    +
                        NBRTRUE(*EQ 1)

