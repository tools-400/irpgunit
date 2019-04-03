      //
      // Library list handling.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,LIBL


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,TEMPLATES
      /copy RPGUNITY1,ERRORCODE
      /copy RPGUNITY1,QWDRJOBD
      /copy RPGUNITY1,QUSRJOBI
      /copy RPGUNITY1,QLICHGLL


      //----------------------------------------------------------------------
      //   Procedure Definitions
      //----------------------------------------------------------------------

     P getLibl...
     P                 b                   export
     D                 pi                  likeds(LiblData_t   )

     D i               s             10i 0
     D liblData        ds                  likeds(LiblData_t)
     D apiInfo         ds                  qualified
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D jobi0700        ds                  likeds(jobi0700_t) based(pJOBI0700)
     D liblE           s             11a   based(pLiblE)
      /free

         QUSRJOBI(
               apiInfo: %size(apiInfo): 'JOBI0700': '*': '': percolateErrors);


         pJOBI0700 = %alloc(apiInfo.bytAvl);

         QUSRJOBI(
               jobi0700: apiInfo.bytAvl: 'JOBI0700': '*': '': percolateErrors);

         clear liblData;
         liblData.libL.numE = jobi0700.numUsrLibE;

         pLiblE = %addr(jobi0700) + %size(jobi0700)
                                  + jobi0700.numSysLibE * 11
                                  + jobi0700.numPrdLibE * 11
                                  + jobi0700.numCurLibE * 11;
         for i = 1 to liblData.libL.numE;
            liblData.libL.lib(i) = liblE;
            pLiblE = pLiblE + 11;
         endfor;

         if (jobi0700.numCurLibE > 0);
            pLiblE = %addr(jobi0700) + %size(jobi0700)
                                     + jobi0700.numSysLibE * 11
                                     + jobi0700.numPrdLibE * 11;
            liblData.curLib = liblE;
         else;
            liblData.curLib = '*CRTDFT';
         endif;

         dealloc(N) pJOBI0700;

         Return liblData;

      /end-free
     P                 e


     P loadLibl...
     P                 b                   export
     D                 pi                  likeds(LiblData_t   )
     D  qJobD                              const  likeds(Object_t  )

     D i               s             10i 0
     D liblData        ds                  likeds(LiblData_t)
     D apiInfo         ds                  qualified
     D  bytRet                       10I 0
     D  bytAvl                       10I 0
     D jobd0100        ds                  likeds(jobd0100_t) based(pJOBD0100)
     D liblE           s             11a   based(pLiblE)
      /free

         QWDRJOBD(
               apiInfo: %size(apiInfo): 'JOBD0100': qJobD: percolateErrors);

         pJOBD0100 = %alloc(apiInfo.bytAvl);

         QWDRJOBD(
               jobd0100: apiInfo.bytAvl: 'JOBD0100': qJobD: percolateErrors);

         clear liblData;
         liblData.libL.numE = jobd0100.numInlLiblE;

         pLiblE = %addr(jobd0100) + jobd0100.ofsInlLibl;
         for i = 1 to liblData.libL.numE;
            liblData.libL.lib(i) = liblE;
            pLiblE = pLiblE + 11;
         endfor;

         liblData.curLib = '*CRTDFT';

         dealloc(N) pJOBD0100;

         Return liblData;

      /end-free
     P                 e


     P restoreLibl...
     P                 b                   export
     D                 pi
     D  liblData                           const  likeds(LiblData_t)

     D i               s             10i 0 inz

     D inlLibL         ds                  qualified
     D  numE                   1      4i 0 inz
     D  lib                    5   2754a   inz dim(250)
     D  libs                   5   2754a
      /free

         for i = 1 to liblData.libL.numE;
            inlLibL.lib(i) = liblData.libL.lib(i);
            inlLibL.numE += 1;
         endfor;

         QLICHGLL(liblData.curLib: '*SAME': '*SAME'
                  : inlLibL.libs: inlLibL.numE: percolateErrors);

      /end-free
     P                 e


     P changeLibl...
     P                 b                   export
     D                 pi
     D  curLib                       10a   const
     D  libL                               const  likeds(LibL_t)

     D i               s             10i 0
     D liblData        ds                  likeds(LiblData_t) inz
      /free

         liblData.curLib = curLib;

         for i = 1 to libL.numE;
            liblData.libL.lib(i) = libL.lib(i);
            liblData.libL.numE += 1;
         endfor;

         restoreLibl(liblData);

      /end-free
     P                 e


     P setTestSuiteLibl...
     P                 b                   export
     D                 pi              n
     D  libl                               value likeds(LibL_t)
     D  jobd                               value likeds(Object_t)
     D  testPgmLib                   10a   Value

     D loadedLibl      ds                  likeds(LiblData_t)
      /free

          select;
          when (libl.numE = 1);
             if (libl.lib(1) = '*JOBD');
                if (jobd.nm = '*DFT');
                   jobd.nm = 'RPGUNIT';
                   jobd.lib = testPgmLib;
                endif;
                loadedLibl = loadLibl(jobd);
                restoreLibl(loadedLibl);
                return *ON;
             endif;

          when (libl.numE > 1);
             changeLibl('*CRTDFT': libL);
             return *ON;
          endsl;

          return *OFF;

      /end-free
     P                 e

