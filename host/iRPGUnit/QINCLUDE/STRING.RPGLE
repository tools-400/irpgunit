      /if not defined(IRPGUNIT_STRING)
      /define IRPGUNIT_STRING
      // ==========================================================================
      //  iRPGUnit - String Utilities.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================

     D uCase           pr                        like(String_t)
     D                                     extproc('STRING_uCase')
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D startsWith...
     D                 pr              N
     D                                     extproc('STRING_startsWith')
     D  prefix                             const like(String_t)
     D                                           options(*varsize)
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D endsWith...
     D                 pr              N
     D                                     extproc('STRING_endsWith')
     D  suffix                             const like(String_t)
     D                                           options(*varsize)
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D contains...
     D                 pr              N
     D                                     extproc('STRING_contains')
     D  text                               const like(String_t)
     D                                           options(*varsize)
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D compare...
     D                 pr              N
     D                                     extproc('STRING_compare')
     D  generic                            const like(String_t)
     D                                           options(*varsize)
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D isQuoted...
     D                 pr              n
     D                                     extproc('STRING_isQuoted')
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D addQuotes...
     D                 pr                        like(String_t)
     D                                     extproc('STRING_addQuotes')
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D removeQuotes...
     D                 pr                        like(String_t)
     D                                     extproc('STRING_removeQuotes')
     D  string                             const like(String_t)
     D                                           options(*varsize)

     D spaces...
     D                 pr                        like(String_t)
     D                                     extproc('STRING_spaces')
     D  length                       10i 0 value
     D  char                          1a   value options(*nopass)

      /endif

