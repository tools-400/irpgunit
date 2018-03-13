
       //----------------------------------------------------------------------
       //   PUBLIC PROTOTYPES
       //----------------------------------------------------------------------

     D getCrtRpgModCmd...
     D                 pr                        like(Cmd_t)
     D  pgm                                const likeds(Object_t)
     D  srcFile                            const likeds(Object_t)
     D  srcMbr                             const like(SrcMbr_t.mbr)
     D  cOptions                           const likeds(Options_t)
     D  dbgView                      10a   const
     D  pOptions                           const likeds(Options_t)
     D  compileopt                 5000a   const varying options(*varsize)

     D getDltModCmd...
     D                 pr                        like(Cmd_t)
     D  testPgm                            const likeds(Object_t)

     D getCrtSrvPgmCmd...
     D                 pr                        like(Cmd_t)
     D  pgm                                const likeds(Object_t)
     D  bndSrvPgm                          const likeds(ObjectArray_t)
     D  bndDir                             const likeds(ObjectArray_t)
     D  module                             const likeds(ObjectArray_t)
     D  options                            const likeds(Options_t)
     D  export                       10a   const
     D  text                               const like(Text_t )

     D serializeObjectArray...
     D                 pr                        like(SerializedArray_t)
     D  headToken                    10a   const
     D  array                              const likeds(ObjectArray_t)

     D serializeObjectName...
     D                 pr            21a   varying
     D  object                             const likeds(Object_t)

     DserializeOptions...
     D                 pr                        like(SerializedOptions_t)
     D headToken                     10a   const
     D options                             const likeds(Options_t)

     DserializeString...
     D                 pr                        like(SerializedString_t)
     D headToken                     10a   const
     D text                        5000a   const varying options(*varsize)

     DserializeValue...
     D                 pr                        like(SerializedString_t)
     D headToken                     10a   const
     D value                               const like(String_t)

     D addTestCaseModule...
     D                 pr                        likeds(ObjectArray_t)
     D  modules                            const likeds(ObjectArray_t)
     D  testCase                           const likeds(Object_t)


       //----------------------------------------------------------------------
       //   TEMPLATES
       //----------------------------------------------------------------------

       // A sized array of OS400 objects.
     D ObjectArray_t   ds                  based(template) qualified
     D  size                          5i 0
     D  object                             Dim(51) likeds(Object_t)

       // A sized list of options.
     D Options_t       ds                  based(template) qualified
     D  size                          5i 0
     D  option                       10a   Dim(25)

     D HeadToken_t     s             10a   based(template)
     D DbgView_t       s             10a   based(template)
     D Export_t        s             10a   based(template)

     D Cmd_t           s           8192a   based(template) varying
     D SerializedArray_t...
     D                 s           2048a   based(template) varying
     D SerializedObject_t...
     D                 s             21a   based(template) varying
     D SerializedOptions_t...
     D                 s            512a   based(template) varying
     D SerializedString_t...
     D                 s           5136a   based(template) varying

