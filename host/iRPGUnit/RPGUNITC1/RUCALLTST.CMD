     /* =================================================================== */
     /*  RPGUnit - Call a test suite by command line.                       */
     /* =================================================================== */
     /*   >>PRE-COMPILER<<                                                  */
     /*     >>CRTCMD<<  CRTCMD        CMD(&LI/&OB) +                        */
     /*                               SRCFILE(&SL/&SF)  +                   */
     /*                               SRCMBR(&SM);                          */
     /*     >>COMPILE<<                                                     */
     /*       >>PARM<< PGM(&LI/RUCALLTST);                                  */
     /*       >>PARM<< HLPPNLGRP(&LI/RUCMDHLP);                             */
     /*       >>PARM<< HLPID(RUCALLTST);                                    */
     /*     >>END-COMPILE<<                                                 */
     /*     >>EXECUTE<<                                                     */
     /*   >>END-PRE-COMPILER<<                                              */
     /* =================================================================== */
             CMD        PROMPT('RPGUnit - Call Tests')

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

