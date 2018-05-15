      //
      // Prototype for RslvSP MI instruction.
      //
      // Resolve System Pointer.
      //

     D rslvSP          pr              *   extproc('rslvsp') procptr
        // Object type (in hexadecimal format -- see QLICVTTP API).
     D  hexType                       2a   Value
        // Object name.
     D  object                         *   Value options(*String)
        // Library name.
     D  lib                            *   Value options(*String)
        // Authority.
     D  auth                          2a   Value

