      * ===================================================================
      *  iRPGUnit - Create iRPGUnit Meta Data.
      * ===================================================================
      * >>PRE-COMPILER<<
      *   >>CRTCMD<< CRTBNDRPG    PGM(&LI/&OB) +
      *                           SRCFILE(&SL/&SF) SRCMBR(&SM);
      *   >>COMPILE<<
      *     >>PARM<< OPTION(*EVENTF);
      *     >>PARM<< TRUNCNBR(*NO);
      *     >>PARM<< DBGVIEW(*LIST);
      *   >>END-COMPILE<<
      *   >>EXECUTE<<
      * >>END-PRE-COMPILER<<
      * ===================================================================
      /include qinclude,H_SPEC
     H DFTACTGRP(*NO) ACTGRP(*NEW)
      * ===================================================================

     fQSRC      UF   F  512        DISK    usropn
     f                                     extfile(g_extFile)
     f                                     extmbr(g_member)
     f                                     infds(g_srcInfo)

     d g_extFile       s             21a
     d g_member        s             10a
     d g_srcInfo       ds                  likeds(srcInfo_t)

     d srcInfo_t       ds                  qualified based(pTemplate)
     d  file                  83     92
     d  lib                   93    102
     d  rcdLen               125    126I 0
     d  mbr                  129    138
     d  recNo                397    400I 0

     d srcLine_t       ds                  qualified based(pTemplate)
     d  seq                    1      6s 0
     d  date                   7     12s 0
     d  data                  13    512a

      /copy qsysinc,regex

      // Replace function

     d replace...
     d                 pr
     d  i_file                       10a   const
     d  i_lib                        10a   const
     d  i_mbr                        10a   const
     d  i_cbReplace                    *   const procptr

      // Replace *EUR and *ISO dates.

     d replaceDates...
     d                 pr              n   extproc('replaceDates')
     d  io_srcLine                               likeds(srcLine_t)
     d  i_srcInfo                          const likeds(srcInfo_t)

      // Replace callback

     d g_cbReplace     s               *   procptr
     d cbReplace...
     d                 pr              n   extproc(g_cbReplace)
     d  io_srcLine                               likeds(srcLine_t)
     d  i_srcInfo                          const likeds(srcInfo_t)

     d open...
     d                 pr                  extproc('open')
     d  i_file                       10a   const
     d  i_lib                        10a   const
     d  i_mbr                        10a   const

     d close...
     d                 pr                  extproc('close')

     d CRTPKGCPR...
     d                 pr                  extpgm('CRTPKGCPR')
     d  gi_lib                       10A   const
     d  go_date                      10A

     d g_now           s               z

     d CRTPKGCPR...
     d                 pi
     d  gi_lib                       10A   const
     d  go_date                      10A
      /free

         g_now = %timestamp();

         replace('QINCLUDE': gi_lib: 'COPYRIGHT': %paddr('replaceDates'));

         go_date = %char(%date(g_now): *EUR);

         *inlr = *on;

      /end-free

      // Read file member add call replace function for each statement.

     p replace...
     p                 b
     d                 pi
     d  i_file                       10a   const
     d  i_lib                        10a   const
     d  i_mbr                        10a   const
     d  i_cbReplace                    *   const procptr

     d srcLine         ds                  likeds(srcLine_t) inz
      /free

         g_cbReplace = i_cbReplace;

         callp open(i_file: i_lib: i_mbr);

         dou (%eof());
            read QSRC srcLine;
            if (not %eof());
               if (cbReplace(srcLine: g_srcInfo));
                  update QSRC srcLine;
               endif;
            endif;
         enddo;

         callp close();

      /end-free
     p                 e

      // Replace *EUR and *ISO dates.

     p replaceDates...
     p                 b
     d                 pi              n
     d  io_srcLine                               likeds(srcLine_t)
     d  i_srcInfo                          const likeds(srcInfo_t)

     d isDirty         s               n

     d date_eur        s             10a
     d date_iso        s             10a
     d date_year       s              4a

     d length          s             10i 0

     d hRegex_eur      ds                  likeds(regex_t) inz
     d hRegex_iso      ds                  likeds(regex_t) inz
     d hRegex_year     ds                  likeds(regex_t) inz
     d rc              s             10I 0
     d cflags          s             10I 0
     d nmatch          s             10U 0 inz(2)
     d regmatch        ds                  likeds(regmatch_t) dim(2) inz
      /free

         isDirty = *off;

         length = i_srcInfo.rcdLen -
                  (%size(io_srcLine.seq) + %size(io_srcLine.date));

         date_eur = %char(%date(g_now): *EUR);
         date_iso = %char(%date(g_now): *ISO);
         date_year = %char(%subdt(g_now: *YEARS));

         dou '1';

            // Compile regular expressions

            cflags = REG_EXTENDED + REG_ICASE;

            rc = regcomp(hRegex_eur
                         : '([0-9x]{2}.[0-9x]{2}.[0-9x]{4})': cflags);
            if (rc <> 0);
               leave;
            endif;

            rc = regcomp(hRegex_iso
                         : '([0-9x]{4}-[0-9x]{2}-[0-9x]{2})': cflags);
            if (rc <> 0);
               leave;
            endif;

            rc = regcomp(hRegex_year
                         : '2013-([0-9x]{4})': cflags);
            if (rc <> 0);
               leave;
            endif;

            // Execute regular expressions

            rc = regexec(hRegex_eur: %subst(io_srcLine.data: 1: length)
                         : nmatch: regmatch: 0);
            if (rc = 0);
               // Replace whole expression
               io_srcLine.data =
                  %replace(date_eur: %subst(io_srcLine.data: 1: length)
                           : regmatch(1).rm_so + 1
                           : regmatch(1).rm_eo - regmatch(1).rm_so);
               isDirty = *on;
            endif;

            rc = regexec(hRegex_iso: io_srcLine.data
                         : nmatch: regmatch: 0);
            if (rc = 0);
               // Replace whole expression
               io_srcLine.data =
                  %replace(date_iso: io_srcLine.data
                           : regmatch(1).rm_so + 1
                           : regmatch(1).rm_eo - regmatch(1).rm_so);
               isDirty = *on;
            endif;

            rc = regexec(hRegex_year: io_srcLine.data
                         : nmatch: regmatch: 0);
            if (rc = 0);
               // Replace first group
               io_srcLine.data =
                  %replace(date_year: io_srcLine.data
                           : regmatch(2).rm_so + 1
                           : regmatch(2).rm_eo - regmatch(2).rm_so);
               isDirty = *on;
            endif;

         enddo;

         // Clear regular expressions

         if (hRegex_eur.re_comp <> *null);
            regfree(hRegex_eur);
         endif;

         if (hRegex_iso.re_comp <> *null);
            regfree(hRegex_iso);
         endif;

         if (hRegex_year.re_comp <> *null);
            regfree(hRegex_year);
         endif;

         return isDirty;

      /end-free
     p                 e

      // Open file member.

     p open...
     p                 b
     d                 pi
     d  i_file                       10a   const
     d  i_lib                        10a   const
     d  i_mbr                        10a   const
      /free

         callp close();

         g_extFile = %trim(i_lib) + '/' + %trim(i_file);
         g_member = %trim(i_mbr);

         open QSRC;

      /end-free
     p                 e

      // Close file member.

     p close...
     p                 b
     d                 pi
      /free

         if (not %open(QSRC));
            return;
         endif;

         close QSRC;

         g_extFile = '';
         g_member = '';

      /end-free
     p                 e


