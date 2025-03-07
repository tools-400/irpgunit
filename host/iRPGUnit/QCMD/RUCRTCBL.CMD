     /* ===================================================================== */
     /*  iRPGUnit - Create Cobol Test Suite.                                  */
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
     /*       >>PARM<< PGM(&LI/RUCRTCBL);                                     */
     /*       >>PARM<< HLPPNLGRP(&LI/RUCRTCBL);                               */
     /*       >>PARM<< HLPID(RUCRTCBL);                                       */
     /*       >>PARM<< OPTION(*EVENTF);                                       */
     /*     >>END-IMPORTANT<<                                                 */
     /*     >>EXECUTE<<                                                       */
     /*   >>END-PRE-COMPILER<<                                                */
     /* ===================================================================== */
             CMD        PROMPT('Create Cobol Test Suite')

             PARM       KWD(TSTPGM)                          +
                          TYPE(PGM)                          +
                          MIN(1)                             +
                          PROMPT('Test program')

             PARM       KWD(SRCFILE)                         +
                          TYPE(FILE)                         +
                          PROMPT('Source file')

             PARM       KWD(SRCMBR)                          +
                          TYPE(*NAME)                        +
                          LEN(10)                            +
                          DFT(*TSTPGM)                       +
                          SPCVAL(*TSTPGM)                    +
                          PROMPT('Source member')

             PARM       KWD(SRCSTMF)                         +
                          TYPE(*CHAR)                        +
                          LEN(4096)                          +
                          VARY(*YES *INT2)                   +
                          MIN(0)                             +
                          CASE(*MIXED)                       +
                          INLPMTLEN(50)                      +
                          PROMPT('Source stream file')

             PARM       KWD(TEXT)                            +
                          TYPE(*CHAR)                        +
                          LEN(50)                            +
                          VARY(*YES *INT2)                   +
                          DFT(*SRCMBRTXT)                    +
                          SPCVAL((*SRCMBRTXT)                +
                                 (*BLANK    )                +
                                 (*DEFAULT  ))               +
                          PROMPT('Text ''description''')

             PARM       KWD(COPTION)                         +
                          TYPE(*CHAR)                        +
                          LEN(12)                            +
                          MAX(10)                            +
                          DFT(*NOMONOPRC)                    +
                          RSTD(*YES)                         +
                          VALUES(*SOURCE                     +
                                 *NOSOURCE                   +
                                 *SRC                        +
                                 *NOSRC                      +
                                 *NOXREF                     +
                                 *XREF                       +
                                 *GEN                        +
                                 *NOGEN                      +
                                 *NOSEQUENCE                 +
                                 *SEQUENCE                   +
                                 *NOVBSUM                    +
                                 *VBSUM                      +
                                 *NONUMBER                   +
                                 *NUMBER                     +
                                 *LINENUMBER                 +
                                 *NOMAP                      +
                                 *MAP                        +
                                 *NOOPTIONS                  +
                                 *OPTIONS                    +
                                 *QUOTE                      +
                                 *APOST                      +
                                 *NOSECLVL                   +
                                 *SECLVL                     +
                                 *PRTCORR                    +
                                 *NOPRTCORR                  +
                                 *MONOPRC                    +
                                 *NOMONOPRC                  +
                                 *RANGE                      +
                                 *NORANGE                    +
                                 *NOUNREF                    +
                                 *UNREF                      +
                                 *NOSYNC                     +
                                 *SYNC                       +
                                 *NOCRTF                     +
                                 *CRTF                       +
                                 *NODUPKEYCHK                +
                                 *DUPKEYCHK                  +
                                 *NOINZDLT                   +
                                 *INZDLT                     +
                                 *NOBLK                      +
                                 *BLK                        +
                                 *STDINZ                     +
                                 *NOSTDINZ                   +
                                 *STDINZHEX00                +
                                 *NODDSFILLER                +
                                 *DDSFILLER                  +
                                 *NOIMBEDERR                 +
                                 *IMBEDERR                   +
                                 *STDTRUNC                   +
                                 *NOSTDTRUNC                 +
                                 *NOCHGPOSSGN                +
                                 *CHGPOSSGN                  +
                                 *NOEVENTF                   +
                                 *EVENTF                     +
                                 *MONOPIC                    +
                                 *NOMONOPIC                  +
                                 *NOCRTARKIDX                +
                                 *CRTARKIDX  )               +
                          PROMPT('Compile options')

             PARM       KWD(DBGVIEW)                         +
                          TYPE(*CHAR)                        +
                          LEN(10)                            +
                          DFT(*LIST)                         +
                          RSTD(*YES)                         +
                          VALUES(*STMT                       +
                                 *SOURCE                     +
                                 *LIST                       +
                                 *ALL                        +
                                 *NONE)                      +
                          PROMPT('Debugging views')


             PARM       KWD(BNDSRVPGM)                       +
                          TYPE(BNDSRVPGM)                    +
                          MAX(50)                            +
                          PROMPT('Bind service program')

             PARM       KWD(BNDDIR)                          +
                          TYPE(BNDDIR)                       +
                          MAX(10)                            +
                          PROMPT('Binding directory')

             PARM       KWD(BOPTION)                         +
                          TYPE(*CHAR)                        +
                          LEN(12)                            +
                          MAX(2)                             +
                          RSTD(*YES)                         +
                          VALUES(*DUPPROC                    +
                                 *DUPVAR)                    +
                          PROMPT('Binding options')

             PARM       KWD(DEFINE)                          +
                          TYPE(*CHAR)                        +
                          LEN(50)                            +
                          MIN(0)                             +
                          MAX(32)                            +
                          DFT(*NONE)                         +
                          SPCVAL((*NONE    *N))              +
                          PROMPT('Define condition names')

             PARM       KWD(DLTSPLF)                         +
                          TYPE(*CHAR)                        +
                          LEN(1)                             +
                          RSTD(*YES)                         +
                          SPCVAL((*YES '1')                  +
                                 (*NO  '0'))                 +
                          DFT(*NO)                           +
                          PROMPT('Delete spooled files')

         /* -------------------------------------- */
         /*   Additional parameters                */
         /* -------------------------------------- */

             PARM       KWD(ACTGRP)                          +
                          TYPE(*NAME)                        +
                          PMTCTL(*PMTRQS)                    +
                          SPCVAL(*CALLER)                    +
                          DFT(*CALLER)                       +
                          PROMPT('Activation group')

             PARM       KWD(MODULE)                          +
                          TYPE(MODULE)                       +
                          MAX(50)                            +
                          PMTCTL(*PMTRQS)                    +
                          PROMPT('Module')

             PARM       KWD(POPTION)                         +
                          TYPE(*CHAR)                        +
                          LEN(12)                            +
                          MAX(9)                             +
                          DFT(*SYSVAL)                       +
                          RSTD(*YES)                         +
                          VALUES(*XREF                       +
                                 *NOXREF                     +
                                 *GEN                        +
                                 *NOGEN                      +
                                 *COMMA                      +
                                 *PERIOD                     +
                                 *JOB                        +
                                 *SYSVAL                     +
                                 *QUOTESQL                   +
                                 *APOSTSQL                   +
                                 *QUOTE                      +
                                 *APOST                      +
                                 *SECLVL                     +
                                 *NOSECLVL                   +
                                 *EVENTF                     +
                                 *NOEVENTF                   +
                                 *CVTDT                      +
                                 *NOCVTDT                    +
                                 *SQL                        +
                                 *SYS                        +
                                 *OPTLOB                     +
                                 *NOOPTLOB                   +
                                 *NOEXTIND                   +
                                 *EXTIND                     +
                                 *SYSTIME                    +
                                 *NOSYSTIME)                 +
                          PMTCTL(*PMTRQS)                    +
                          PROMPT('Pre-compiler OPTIONS')

             PARM       KWD(COMPILEOPT)                      +
                          TYPE(*CHAR)                        +
                          LEN(5000)                          +
                          VARY(*YES *INT2)                   +
                          PMTCTL(*PMTRQS)                    +
                          PROMPT('Pre-Compiler COMPILEOPT')

             PARM       KWD(TGTRLS)                          +
                          TYPE(*NAME)                        +
                          PMTCTL(*PMTRQS)                    +
                          SPCVAL(*CURRENT *PRV)              +
                          DFT(*CURRENT)                      +
                          PROMPT('Target release')

             PARM       KWD(INCDIR)                          +
                          TYPE(*CHAR)                        +
                          PMTCTL(*PMTRQS)                    +
                          LEN(4096)                          +
                          VARY(*YES *INT2)                   +
                          DFT(*NONE)                         +
                          SNGVAL(*NONE)                      +
                          MIN(0)                             +
                          MAX(32)                            +
                          CASE(*MIXED)                       +
                          INLPMTLEN(50)                      +
                          PROMPT('Include directory')

             PARM       KWD(TGTCCSID)                        +
                          TYPE(*INT4)                        +
                          PMTCTL(*PMTRQS)                    +
                          DFT(*SRC)                          +
                          SPCVAL((*JOB -1)                   +
                                 (*SRC -2))                  +
                          PROMPT('Target CCSID')


 PGM:        QUAL       TYPE(*NAME) LEN(10)
             QUAL       TYPE(*NAME) LEN(10) DFT(*CURLIB) SPCVAL(*CURLIB)     +
                        PROMPT('Library')

 FILE:       QUAL       TYPE(*NAME) LEN(10) DFT(QCBLLESRC)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL(*LIBL *CURLIB) +
                        PROMPT('Library')

 BNDSRVPGM:  QUAL       TYPE(*NAME) LEN(10) DFT(*NONE) SPCVAL(*NONE)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL(*LIBL)         +
                        PROMPT('Library')

 BNDDIR:     QUAL       TYPE(*NAME) LEN(10) DFT(*NONE) SPCVAL(*NONE)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL(*LIBL *CURLIB *USRLIBL) +
                        PROMPT('Library')

 MODULE:     QUAL       TYPE(*NAME) LEN(10) DFT(*NONE) SPCVAL(*NONE)
             QUAL       TYPE(*NAME) LEN(10) DFT(*LIBL) SPCVAL(*LIBL *CURLIB *USRLIBL) +
                        PROMPT('Library')

