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
      /include qsysinc,stat

      //----------------------------------------------------------------------
      //   Private Prototypes
      //----------------------------------------------------------------------

      // Replace all occurences of a given search argument.
     D replace...
     D                 pr          2048a   varying
     D                                     extproc('replace')
     D  i_string                   2048a   const varying options(*varsize)
     D  i_searchArg                 512a   const varying options(*varsize)
     D  i_replaceArg                512a   const varying options(*varsize)

     D validateReplacementVariables...
     D                 pr           256a   varying
     D  i_xmlStmf                          const like(stmf_t)

     D getDirectory...
     D                 pr                  like(stmf_t)
     D                                     extproc('getDirectory')
     D i_path                              const like(stmf_t)

       //----------------------------------------------------------------------
       //   Main Procedure
       //----------------------------------------------------------------------

     D cmdRunV...
     D                 pi
     D  gi_testSuite                       const likeds(Object_t)
     D  gi_testProcs                       const likeds(ProcNms_t)
     D  gi_order                           const like(order_t)
     D  gi_detail                          const like(detail_t)
     D  gi_output                          const like(output_t)
     D  gi_libl                            const likeds(LibL_t)
     D  gi_jobd                            const likeds(Object_t)
     D  gi_rclRsc                          const like(rclrsc_t)
     D  gi_xmlStmf                         const like(stmf_t)

     D errMsg          s            256a   varying
      /free

       if (gi_xmlStmf <> '');

         errMsg = validateXmlStmf(gi_xmlStmf: gi_testSuite);
         if (errMsg <> '');
           sndVldChkMsg( errMsg : 2 );
         endif;

       endif;

       *inlr = *on;

       return;

      /end-free


       //----------------------------------------------------------------------
       //   Procedures
       //----------------------------------------------------------------------

     P validateXmlStmf...
     P                 b                   export
     D                 pi           256a   varying
     D  i_xmlStmf                          const like(stmf_t)
     D  i_testSuite                        const likeds(object_t )

     D errMsg          s            256a   varying
     D xmlStmfRpl      s                   like(i_xmlStmf)
     D dir             s                   like(i_xmlStmf)
     D st_stat         ds                  likeds(st_stat_t)
      /free

         // Validate replacement variables
         errMsg = validateReplacementVariables(i_xmlStmf);
         if (errMsg <> '');
           return errMsg;
         endif;

         // Replace variables
         monitor;
           xmlStmfRpl = resolvePathVariables(i_xmlStmf : i_testSuite);
         on-error;
           errMsg = rcvMsgTxt('*ESCAPE');
           if (errMsg <> '');
             return errMsg;
           endif;
         endmon;

         // Ensure all replacement variables have been replaced
         if (%scan('<': xmlStmfRpl) > 0 or %scan('>': xmlStmfRpl) > 0);
           errMsg = 'Not all replacement variables have been replaced. +
                     Check parameter TSTPGM.';
           return errMsg;
         endif;

         // Ensure directory exists
         dir = getDirectory(xmlStmfRpl);
         if (stat(dir: st_stat)  < 0);
           errMsg = 'Directory does not exist. +
                     Check parameter ''XML stream file'' (XMLSTMF).';
           return errMsg;
         endif;

         return '';

      /end-free
     P                 e

     P validateReplacementVariables...
     P                 b
     D                 pi           256a   varying
     D  i_xmlStmf                          const like(stmf_t)

     D errMsg          s            256a   varying

     D illegalRplVar   s             10a   varying
     D illegalMsg      s            128a   varying
      /free

         select;
         when (%scan('%c': i_xmlStmf) > 0);
           illegalRplVar = '%c';   // Date/Time in the format of the locale.
           illegalMsg = 'may contain illegal characters';
         when (%scan('%D': i_xmlStmf) > 0);
           illegalRplVar = '%D';   // Date Format, same as %m/%d/%y.
           illegalMsg = 'contains forward slashes';
         when (%scan('%e': i_xmlStmf) > 0);
           illegalRplVar = '%e';   // Same as %d, except single digit is
           // preceded by a space [1-31].
           illegalMsg = 'contains spaces';
         when (%scan('%G': i_xmlStmf) > 0);
           illegalRplVar = '%G';   // 4 digit year portion of ISO week date.
           // Can be negative.
           illegalMsg = 'can be negative';
         when (%scan('%n': i_xmlStmf) > 0);
           illegalRplVar = '%n';   // Newline character.
           illegalMsg = 'newline character';
         when (%scan('%r': i_xmlStmf) > 0);
           illegalRplVar = '%r';   // Time in AM/PM format of the locale.
           illegalMsg = 'may contain illegal characters';
         when (%scan('%t': i_xmlStmf) > 0);
           illegalRplVar = '%t';   // Tab character.
           illegalMsg = 'tab character';
         when (%scan('%x': i_xmlStmf) > 0);
           illegalRplVar = '%x';   // Date in the format of the locale.
           illegalMsg = 'may contain illegal characters';
         when (%scan('%X': i_xmlStmf) > 0);
           illegalRplVar = '%X';   // Time in the format of the locale.
           illegalMsg = 'may contain illegal characters';
         when (%scan('%Y': i_xmlStmf) > 0);
           illegalRplVar = '%Y';   // 4-digit year. Can be negative.
           illegalMsg = 'can be negative';
         when (%scan('%%': i_xmlStmf) > 0);
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
         endif;

        return errMsg;

      /end-free
     P                 e

     P resolvePathVariables...
     P                 b                   export
     D                 pi                  like(stmf_t)
     D  i_path                             const like(stmf_t)
     D  i_testSuite                         const likeds(Object_t)

     D resolvedPath    s                   like(stmf_t)

     D tm              ds                  likeds(tm_t) based(pTm)
     D tmpPathBuf      s           1024a   inz
     D size            s             10i 0
      /free

        pTm = localtime(time(*null));
        size = strftime(
                 %addr(tmpPathBuf): %size(tmpPathBuf): i_path: tm);
        resolvedPath = %subst(tmpPathBuf: 1: size);
        resolvedPath = replace(resolvedPath: '<TSTPGM>': i_testSuite.nm);
        resolvedPath = replace(resolvedPath: '<TSTLIB>': i_testSuite.lib);
        resolvedPath = replace(resolvedPath: ':': '.');
        resolvedPath = replace(resolvedPath: %char(BACK_SLASH): '/');

        return resolvedPath;

      /end-free
     P                 e

     P replace...
     P                 b
     D                 pi          2048a   varying
     D  i_string                   2048a   const varying options(*varsize)
     D  i_searchArg                 512a   const varying options(*varsize)
     D  i_replaceArg                512a   const varying options(*varsize)

     D result          s           2048a   varying
     D startPos        s             10i 0 inz(1)
     D x               s             10i 0
     D theSearchArg    s                   like(i_searchArg)
     D UC              c                   'ABCDEFGHIJKLMNOPQRSTUVWXYC'
     D LC              c                   'abcdefghijklmnopqrstuvwxyz'
      /free

        result = i_string;

        theSearchArg = %xlate(LC: UC: i_searchArg);
        exsr performReplace;

        theSearchArg = %xlate(UC: LC: i_searchArg);
        exsr performReplace;

        return result;

        begsr performReplace;

          x = %scan(theSearchArg: result: startPos);
          dow   x > 0;
            result = %replace(i_replaceArg: result: x: %len(theSearchArg));
            x = x + %len(i_replaceArg);
            if (x <= %len(result));
              x = %scan(theSearchArg: result: x);
            else;
              leave;
            endif;
          enddo;

        endsr;

      /end-free
     P                 e

     P getDirectory...
     P                 b
     D                 pi                  like(stmf_t)
     D i_path                              const like(stmf_t)

     D directory       s                   like(stmf_t)

     D tPath           s                   like(i_path)
     D char            s              1a
     D pathLength      s             10i 0
     D x               s             10i 0
      * ---------------------------------------------------------
      /free

         tPath = %trimr(i_path);

         char = %subst(tPath: %len(tPath): 1);
         if (char = %char(SLASH));
           return i_path;
         else;
           pathLength = %len(tPath);
           for  x = pathLength downto 1;
             char = %subst(tPath: x: 1);
             if (char = %char(COLON) or char = %char(SLASH));
               tPath = %subst(tPath: 1: x);
               return tPath;
             endif;
           endfor;
         endif;

         return directory;

      /end-free
     P                 e

