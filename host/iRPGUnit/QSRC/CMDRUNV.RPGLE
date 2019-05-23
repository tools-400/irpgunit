      // ==========================================================================
       //  iRPGUnit - RUCALLTST Validity checking program.
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
       //   >>EXECUTE<<
       // >>END-PRE-COMPILER<<
      // ==========================================================================

      /include qinclude,H_SPEC
      /include qinclude,COPYRIGHT

       //----------------------------------------------------------------------
       //   Exported Procedures
       //----------------------------------------------------------------------

      /include qinclude,CMDRUNV

       //----------------------------------------------------------------------
       //   Imported Procedures
       //----------------------------------------------------------------------

      /include qinclude,TEMPLATES
      /include qinclude,PGMMSG
      /include qsysinc,strftime
      /include qsysinc,time

      //----------------------------------------------------------------------
      //   Private Prototypes
      //----------------------------------------------------------------------

      // Replace all occurences of a given search argument.
     D replace...
     D                 pr          2048a   varying
     D  string                     2048a   const varying options(*varsize)
     D  searchArg                   512a   const varying options(*varsize)
     D  replaceArg                  512a   const varying options(*varsize)

       //----------------------------------------------------------------------
       //   Main Procedure
       //----------------------------------------------------------------------

     D cmdRunV...
     D                 pi
     D  testSuiteName                      const likeds(Object_t)
     D  testProcs                          const likeds(ProcNms_t)
     D  order                              const like(order_t)
     D  detail                             const like(detail_t)
     D  output                             const like(output_t)
     D  libl                               const likeds(LibL_t)
     D  jobd                               const likeds(Object_t)
     D  rclRsc                             const like(rclrsc_t)
     D  xmlStmf                            const like(stmf_t)

     D errMsg          s            256a
     D illegalRplVar   s             10a   varying
     D illegalMsg      s            128a   varying
     D xmlStmfRpl      s                   like(xmlStmf)
      /free

       // Return result to xml file
       if (xmlStmf <> '');

         select;
         when (%scan('%c': xmlStmf) > 0);
           illegalRplVar = '%c';   // Date/Time in the format of the locale.
           illegalMsg = 'may contain illegal characters';
         when (%scan('%D': xmlStmf) > 0);
           illegalRplVar = '%D';   // Date Format, same as %m/%d/%y.
           illegalMsg = 'contains forward slashes';
         when (%scan('%e': xmlStmf) > 0);
           illegalRplVar = '%e';   // Same as %d, except single digit is
           // preceded by a space [1-31].
           illegalMsg = 'contains spaces';
         when (%scan('%G': xmlStmf) > 0);
           illegalRplVar = '%G';   // 4 digit year portion of ISO week date.
           // Can be negative.
           illegalMsg = 'can be negative';
         when (%scan('%n': xmlStmf) > 0);
           illegalRplVar = '%n';   // Newline character.
           illegalMsg = 'newline character';
         when (%scan('%r': xmlStmf) > 0);
           illegalRplVar = '%r';   // Time in AM/PM format of the locale.
           illegalMsg = 'may contain illegal characters';
         when (%scan('%t': xmlStmf) > 0);
           illegalRplVar = '%t';   // Tab character.
           illegalMsg = 'tab character';
         when (%scan('%x': xmlStmf) > 0);
           illegalRplVar = '%x';   // Date in the format of the locale.
           illegalMsg = 'may contain illegal characters';
         when (%scan('%X': xmlStmf) > 0);
           illegalRplVar = '%X';   // Time in the format of the locale.
           illegalMsg = 'may contain illegal characters';
         when (%scan('%Y': xmlStmf) > 0);
           illegalRplVar = '%Y';   // 4-digit year. Can be negative.
           illegalMsg = 'can be negative';
         when (%scan('%%': xmlStmf) > 0);
           illegalRplVar = '%%';   // % character.
           illegalMsg = '% character';
         other;
           illegalRplVar = '';
           illegalMsg = '';
         endsl;

         if (illegalRplVar <> '');
           errMsg = 'Illegal replacement variable in XML stream file name: ' +
                    illegalRplVar;
           if (illegalMsg <> '');
             errMsg = %trimr(errMsg) + ' (' + illegalMsg + ')';
           endif;
           sndVldChkMsg( errMsg : 2 );
         endif;

         monitor;
           xmlStmfRpl = resolvePathVariables(xmlStmf : testSuiteName);
         on-error;
           errMsg = rcvMsgTxt('*ESCAPE');
         endmon;

         if (errMsg <> '');
           sndVldChkMsg( errMsg : 2 );
         endif;

         if (%scan('<': xmlStmfRpl) > 0 or %scan('>': xmlStmfRpl) > 0);
           errMsg = 'Not all replacement variables have been replaced';
           sndVldChkMsg( errMsg : 2 );
         endif;

       endif;

       *inlr = *on;

       return;

      /end-free

     P resolvePathVariables...
     P                 b                   export
     D                 pi                  like(stmf_t)
     D  path                               const like(stmf_t)
     D  testSuiteName                      const likeds(Object_t)

     D resolvedPath    s                   like(stmf_t)

     D tm              ds                  likeds(tm_t) based(pTm)
     D tmpPathBuf      s           1024a   inz
     D size            s             10i 0
      /free

        pTm = localtime(time(*null));
        size = strftime(
                 %addr(tmpPathBuf): %size(tmpPathBuf): path: tm);
        resolvedPath = %subst(tmpPathBuf: 1: size);
        resolvedPath = replace(resolvedPath: '<TSTPGM>': testSuiteName.nm);
        resolvedPath = replace(resolvedPath: '<TSTLIB>': testSuiteName.lib);
        resolvedPath = replace(resolvedPath: ':': '.');

        return resolvedPath;

      /end-free
     P                 e

     P replace...
     P                 b
     D                 pi          2048a   varying
     D  string                     2048a   const varying options(*varsize)
     D  searchArg                   512a   const varying options(*varsize)
     D  replaceArg                  512a   const varying options(*varsize)

     D result          s           2048a   varying
     D startPos        s             10i 0 inz(1)
     D x               s             10i 0
     D theSearchArg    s                   like(searchArg)
     D UC              c                   'ABCDEFGHIJKLMNOPQRSTUVWXYC'
     D LC              c                   'abcdefghijklmnopqrstuvwxyz'
      /free

        result = string;

        theSearchArg = %xlate(LC: UC: searchArg);
        exsr performReplace;

        theSearchArg = %xlate(UC: LC: searchArg);
        exsr performReplace;

        return result;

        begsr performReplace;

          x = %scan(theSearchArg: result: startPos);
          dow   x > 0;
            result = %replace(replaceArg: result: x: %len(theSearchArg));
            x = x + %len(replaceArg);
            if (x <= %len(result));
              x = %scan(theSearchArg: result: x);
            else;
              leave;
            endif;
          enddo;

        endsr;

      /end-free
     P                 e

