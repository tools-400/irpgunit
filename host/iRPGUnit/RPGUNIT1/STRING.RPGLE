      //
      // String procedures.
      //

     H NoMain
      /copy RPGUNITY1,H_SPEC

      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,STRING


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNITY1,QLGCNVCS


      //----------------------------------------------------------------------
      //   Private Procedures
      //----------------------------------------------------------------------


      //----------------------------------------------------------------------
      //   Type Templates
      //----------------------------------------------------------------------
      /copy RPGUNITY1,TEMPLATES

     D errCode_t       ds                  qualified               based(pDummy)
     D  bytPrv                       10i 0
     D  bytAvl                       10i 0
     D  excID                         7A
     D  reserved_1                    1A
     D  excDta                      512A


      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------


      //----------------------------------------------------------------------
      //   Procedure Definitions
      //----------------------------------------------------------------------


     P uCase...
     P                 b                   export
     D                 pi                        like(String_t)
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D uCase           s           4096A   varying inz

     D stringBuf       S           4096A   inz
     D errCode         DS                  likeds(errCode_t ) inz

     D reqCtrlBlk      DS                  likeds(reqCtrlBlk_ccsid_t) inz

      /free

        if (string = '');
           return string;
        endif;

        clear reqCtrlBlk;
        reqCtrlBlk.type     = cCVTCASE_TYPE_ccsid;
        reqCtrlBlk.CCSID    = cCVTCASE_CCSID_Job;
        reqCtrlBlk.case     = cCVTCASE_toUpper;
        reqCtrlBlk.reserved = *ALLx'00';
        clear errCode;
        QlgConvertCase(reqCtrlBlk:
                       string: stringBuf: %len(string): errCode);
        uCase = %subst(stringBuf: 1: %len(string));

        return uCase;

      /end-free
     P                 e


     P startsWith...
     P                 b                   export
     D                 pi              N
     D  prefix                             const like(String_t)
     D                                           options(*varsize)
     D  string                             const like(String_t)
     D                                           options(*varsize)

      // Return value
     D startsWith      s               N   inz(*OFF)
      /free

         if (%len(string) = 0  or
             %len(prefix) = 0  or
             %len(string) < %len(prefix));
            return *OFF;
         endif;

         if (uCase(%subst(string: 1: %len(prefix))) <> uCase(prefix));
            return *OFF;
         endif;

         return *ON;

      /end-free
     P                 e


     P endsWith...
     P                 b                   export
     D                 pi              N
     D  prefix                             const like(String_t)
     D                                           options(*varsize)
     D  string                             const like(String_t)
     D                                           options(*varsize)

      // Return value
     D endsWith        s               N   inz(*OFF)
      /free

         if (%len(string) = 0  or
             %len(prefix) = 0  or
             %len(string) < %len(prefix));
            return *OFF;
         endif;

         if (uCase(prefix) <>
             uCase(%subst(string: %len(string)-%len(prefix)+1: %len(prefix))));
            return *OFF;
         endif;

         return *ON;

      /end-free
     P                 e


     P isQuoted...
     P                 b                   export
     D                 pi              n
     D  text                               const like(String_t)
     D                                           options(*varsize)
      /free

        if %Len(text) = 0;
          return *OFF;
        endif;

        if not startsWith(QUOTE: %TrimR(text)) or
           not endsWith(QUOTE: %TrimR(text));
          return *OFF;
        endif;

        return *ON;

      /end-free
     P                 e


     P addQuotes...
     P                 b                   export
     D                 pi                        like(String_t)
     D  text                               const like(String_t)
     D                                           options(*varsize)

     D quoted          s                   like(text)
     D i               s             10i 0
      /free

        if %Len(text) = 0;
          return '';
        endif;

        if isQuoted(%Trim(text));
           return text;
        endif;

        quoted = QUOTE;

        for i = 1 to %Len(%TrimR(text));
           quoted += %Subst(text: i: 1);
           if %Subst(text: i: 1) = QUOTE;
              quoted += QUOTE;
           endif;
        endfor;

        quoted += QUOTE;

        return quoted;

      /end-free
     P                 e


     P removeQuotes...
     P                 b                   export
     D                 pi                        like(String_t)
     D  text                               const like(String_t)
     D                                           options(*varsize)

     D unquoted        s                   like(text)
     D i               s             10i 0
      /free

        if %Len(text) = 0;
          return '';
        endif;

        if not isQuoted(%Trim(text));
           return text;
        endif;

        for i = 2 to %Len(%TrimR(text)) - 1;
           unquoted += %Subst(text: i: 1);
           if %Subst(text: i: 1) = QUOTE;
              i += 1;
           endif;
        endfor;

        return unquoted;

      /end-free
     P                 e


     P spaces...
     P                 b                   export
     D                 pi                        like(String_t)
     D  length                       10i 0 value
     D  char                          1a   value options(*nopass)

     D p_char          c                   2
     D i               s             10i 0
     D rtnSpaces       s           5120a   static
     D rtnChars        s                   static like(rtnSpaces)

     D ebcdic          DS                  qualified based(pEbcdic)
     D  char                   1      1A
     D  integer                1      1U 0
      //  memset -- Set Bytes to Value
      //    The memset() function returns a pointer to dest.
     D memset          PR              *          extproc('memset')
     D  i_pDest                        *   value
     D  i_char                       10I 0 value
     D  i_count                      10U 0 value
      /free

        if (length <= 0);
          return '';
        endif;

        if (length > %len(rtnSpaces));
           length = %len(rtnSpaces);
        endif;

        if (%parms() >= p_char);
          if (char <> '');
            pEbcdic = %addr(char);
            memset(%addr(rtnChars): ebcdic.integer: length);
            return %subst(rtnChars: 1: length);
          endif;
        endif;

        return %subst(rtnSpaces: 1: length);

      /end-free
     P                 e

