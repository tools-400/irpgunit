**FREE
/if not defined(IRPGUNIT_CVTHC)
/define IRPGUNIT_CVTHC

//  Convert Hex to Character (CVTHC)
dcl-pr cvthc extproc('cvthc');
  pResult    pointer value;
  pSource    pointer value;
  sourceSize int(10) value;
end-pr;

/endif
