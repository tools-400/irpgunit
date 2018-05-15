      /if defined(RUMODSRC)
      /eof
      /endif
      /define RUMODSRC

      /copy RPGUNITY1,TEMPLATES

     D SrcMbr_initialize...
     D                 pr
     D                                     extproc('SRCMBR_+
     D                                     SrcMbr_initialize+
     D                                     ')

     D SrcMbr_getTestSuiteSrc...
     D                 pr                         likeds(SrcMbr_t)
     D                                     extproc('SRCMBR_+
     D                                     SrcMbr_getTestSuiteSrc+
     D                                     ')
     D  object                             const  likeds(Object_t)

     D SrcMbr_getModSrc...
     D                 pr                         likeds(SrcMbr_t)
     D                                     extproc('SRCMBR_+
     D                                     SrcMbr_getModSrc+
     D                                     ')
     D  object                             const  likeds(Object_t)
     D  module                             const  likeds(Object_t)

