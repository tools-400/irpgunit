**FREE
/if not defined (irpgunit_qusptrus)
/define irpgunit_qusptrus

//
// Retrieve pointer to user space API
//

dcl-pr qusptrus extpgm('QUSPTRUS');
  usrSpc          char(20) const;
  pointer         pointer;
  errorCode       char(32767) options(*nopass : *varsize);               // | OptGrp 1
end-pr;

/endif

