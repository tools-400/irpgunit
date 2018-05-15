      //
      // Spool file test helper.
      //

     D chkAndCloSplF   pr                  extproc('chkAndCloSplF')

     D cloSplf         pr                  extproc('cloSplf')

     D opnSplf         pr                  extproc('opnSplf')
     D  splfNm                       10a   const
     D  usrData                      10a   const

     D splfLineStartsWith...
     D                 pr                  extproc('splfLineStartsWith')
     D  expString                   256a   const varying

     DsplfSkipLine...
     D                 pr                  extproc('splfSkipLine')

