**FREE
/IF NOT DEFINED(GETWCD)
/DEFINE GETWCD

// getcwd()--Get Current Directory
dcl-pr getcwd pointer extproc('getcwd');
  o_path   char(65535) options(*varsize) const;
  i_size   uns(10) value;
end-pr;

/ENDIF
