**FREE
/if not defined (irpgunit_quscrtus)
/define irpgunit_quscrtus

//
// Create User Space API
//

dcl-pr quscrtus extpgm('QUSCRTUS');
  usrSpc          char(20) const;
  extAttr         char(10) const;
  initSize        int(10) const;
  initVal         char(1) const;
  publicAuth      char(10) const;
  text            char(50) const;
  replace         char(10) const;
  error           char(32766) options(*varsize) noopt;
end-pr;

// User Space creation parameters.
dcl-ds usrSpcCrtParm_t qualified template;
  nm              char(20);
  attribute       char(10);
  size            int(10);
  value           char(1);
  auth            char(10);
  text            char(50);
  replace         char(10);
end-ds;

/endif
