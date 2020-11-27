      // ==========================================================================
      //  iRPGUnit SelfTest - Test STRING.
      // ==========================================================================
      //  Copyright (c) 2013-2019 iRPGUnit Project Team
      //  All rights reserved. This program and the accompanying materials
      //  are made available under the terms of the Common Public License v1.0
      //  which accompanies this distribution, and is available at
      //  http://www.eclipse.org/legal/cpl-v10.html
      // ==========================================================================
      // >>PRE-COMPILER<<
      //   >>CRTCMD<<  RUCRTRPG TSTPGM(&LI/&OB) SRCFILE(&SL/&SF) SRCMBR(&SM);
      //   >>IMPORTANT<<
      //     >>PARM<<  MODULE(&LI/STRING    +
      //                      );
      //   >>END-IMPORTANT<<
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D testUCase...
     D                 pr                  extproc('testUCase')

     D testStartsWith...
     D                 pr                  extproc('testStartsWith')

     D testEndsWith...
     D                 pr                  extproc('testEndsWith')

     D testIsQuoted...
     D                 pr                  extproc('testIsQuoted')

     D testAddQuotes...
     D                 pr                  extproc('testAddQuotes')

     D testRemoveQuotes...
     D                 pr                  extproc('testRemoveQuotes')

     D testSpaces...
     D                 pr                  extproc('testSpaces')

     D testSpacesWithChar...
     D                 pr                  extproc('testSpacesWithChar')

     D testSpacesTooLong...
     D                 pr                  extproc('testSpacesTooLong')

     D testContains...
     D                 pr                  extproc('testContains')

     D testCompare...
     D                 pr                  extproc('testCompare')


      //----------------------------------------------------------------------
      //   Global Constants
      //----------------------------------------------------------------------

     D FOX             c                    'The quick brown fox jumps over +
     D                                      the lazy dog.'



      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy qinclude,ASSERT
      /copy qinclude,STRING
      /copy qinclude,TEMPLATES


      //----------------------------------------------------------------------
      //   Tests
      //----------------------------------------------------------------------

     P testUCase...
     P                 b                   export
     D                 pi

     D uString         s            512a   varying inz
      /free

        // Setup.


        // Run.

        uString = uCase('abcdefghijklmnopqrstuvwxyz');

        // Check.

        aEqual('ABCDEFGHIJKLMNOPQRSTUVWXYZ' : uString);

      /end-free
     P                 e

     P testLeftStr...
     P                 b                   export
     D                 pi

     D HELLO_WORLD     c                   'Hello World'

     D errMsgInfo      ds                  likeds(MsgInfo_t) inz
      /free

        // Setup.

        // Run.

        // Check.

        assert(leftStr(HELLO_WORLD: %len(HELLO_WORLD) + 1) = HELLO_WORLD:
               'Expected the complete input string (length > len(input))');

        assert(leftStr(HELLO_WORLD: %len(HELLO_WORLD)) = HELLO_WORLD:
               'Expected the complete input string (length = len(input))');

        assert(leftStr(HELLO_WORLD: 5) = 'Hello':
               'Expected: Hello');

        assert(leftStr(HELLO_WORLD: 0) = '':
               'Expected: empty string');

        monitor;
           assert(leftStr(HELLO_WORLD: -1) = '':
                  'Expected RNX0100: Length or start position is out of range');
           fail( 'Expected to see a RPG runtime exception' );
        on-error;
           errMsgInfo = getMonitoredMessage(*ON);
           assert(errMsgInfo.id = 'RNX0100':
                  'Expected RNX0100: Length or start position is out of range');
        endmon;


      /end-free
     P                 e

     P testStartsWith...
     P                 b                   export
     D                 pi
      /free

        // Setup.

        // Run.

        // Check.

        assert(startsWith('Hello': 'Hello World'):
               '''Hello World'' starts with ''Hello''');

        assert(startsWith('hello': 'Hello World'):
               '''Hello World'' starts with ''hello''');

        assert(not startsWith('hello': '   Hello World'):
               ''' Hello World'' does not start with ''hello'' due +
               to leading spaces');

        assert(not startsWith('hello': 'Greet the World'):
               '''Greet the World'' obviously does not start with ''hello''');

      /end-free
     P                 e

     P testEndsWith...
     P                 b                   export
     D                 pi
      /free

        // Setup.

        // Run.

        // Check.

        assert(endsWith('World': 'Hello World'):
               '''Hello World'' ends with ''world''');

        assert(endsWith('world': 'Hello World'):
               '''Hello World'' ends with ''world''');

        assert(not endsWith('world': 'Hello World   '):
               ''' Hello World'' does not end with ''world'' due +
               to trailing spaces');

        assert(not endsWith('greet': 'Greet the World'):
               '''Greet the World'' obviously does not end with ''greet''');

      /end-free
     P                 e

     P testIsQuoted...
     P                 b                   export
     D                 pi
      /free

        // Setup.

        // Run.

        // Check.

        assert(isQuoted(QUOTE + 'A simple quoted string' + QUOTE):
               'String passed to testIsQuoted() is quoted');

        assert(not isQuoted('A simple string without quotes'):
               'String passed to testIsQuoted() is not quoted');

        assert(not isQuoted(QUOTE + 'A simple string starting with a quote'):
               'String passed to testIsQuoted() is not quoted due +
               to missing end quote'); // Starting quote is recognized as apostrophe

        assert(not isQuoted('A simple string ending with a quote' + QUOTE):
               'String passed to testIsQuoted() is not quoted due +
               to missing start quote'); // Ending quote is recognized as apostrophe

      /end-free
     P                 e

     P testAddQuotes...
     P                 b                   export
     D                 pi

     D string          s            128a   varying
     D quoted          s            128a   varying
      /free

        // Setup.

        // Run.

        // Check.

        string = QUOTE + 'A simple quoted string' + QUOTE;
        quoted = addQuotes(string);
        aEqual(string: quoted);   // String must be unchanged.

        string = 'A simple string without quotes';
        quoted = addQuotes(string);
        aEqual(QUOTE + 'A simple string without quotes' + QUOTE: quoted);

        string = 'Programmer''s coffee cup';
        quoted = addQuotes(string);
        aEqual(QUOTE + 'Programmer' + QUOTE + QUOTE + 's coffee cup' + QUOTE
               : quoted);

        string = QUOTE + 's coffee cup';
        quoted = addQuotes(string);
        // String gets quoted and leading apostrophe is doubled
        aEqual(QUOTE + QUOTE + QUOTE + 's coffee cup' + QUOTE: quoted);

        string = 'coffee cup' + QUOTE;
        quoted = addQuotes(string);
        // String gets quoted and ending apostrophe is doubled
        aEqual(QUOTE + 'coffee cup' + QUOTE + QUOTE + QUOTE: quoted);

      /end-free
     P                 e

     P testRemoveQuotes...
     P                 b                   export
     D                 pi

     D expected        s            128a   varying
     D actual          s            128a   varying
      /free

        // Setup.

        // Run.

        // Check.

        expected = QUOTE + 'A simple quoted string' + QUOTE;
        actual = addQuotes(removeQuotes(expected));
        aEqual(expected: actual);

        expected = 'A simple string without quotes';
        actual = removeQuotes(expected);
        aEqual(expected: actual);

        expected = 'Programmer''s coffee cup'; // embedded apostrophe
        actual = removeQuotes(addQuotes(expected));
        aEqual(expected: actual);

        expected = QUOTE + 's coffee cup'; // leading apostrophe
        actual = removeQuotes(addQuotes(expected));
        aEqual(expected: actual);

        expected = 'coffee cup' + QUOTE; // trailing apostrophe
        actual = removeQuotes(addQuotes(expected));
        aEqual(expected: actual);

      /end-free
     P                 e

     P testSpaces...
     P                 b                   export
     D                 pi

     D expected        s            128a   varying
      /free

        // Setup.

        expected = 'Donald   Duck';

        // Run.

        // Check.

        aEqual(expected: 'Donald' + spaces(3) + 'Duck');

      /end-free
     P                 e

     P testSpacesWithChar...
     P                 b                   export
     D                 pi

     D expected        s            128a   varying
      /free

        // Setup.

        expected = 'Donald---Duck';

        // Run.

        // Check.

        aEqual(expected: 'Donald' + spaces(3: '-') + 'Duck');

      /end-free
     P                 e

     P testSpacesTooLong...
     P                 b                   export
     D                 pi

     D expected        s           8000a   varying
     D actual          s           8000a   varying
     D tmpString       s                   like(String_t)
     D maxSpaces       s             10i 0
      /free

        // Setup.

        maxSpaces = %size(tmpString) - 2;
        assert(maxSpaces < %size(expected) - 2:
               'Field ''expected'' must be longer than ' + %char(maxSpaces));

        // Run.

        expected = 'Donald' + spaces(maxSpaces) + 'Duck';
        actual = 'Donald' + spaces(maxSpaces * 2) + 'Duck';

        // Check.

        aEqual(expected: actual);

      /end-free
     P                 e


     P testContains...
     P                 b                   export
     D                 pi

     D result          s               n
      /free

        // Check not found.

        result = contains( 'foo bar' : FOX);
        assert( not result :
          'contains() must return FALSE, +
           because string does not contain ''foo bar''' );

        // Check.

        result = contains( 'The' : FOX);
        assert( result :
          'contains() must return TRUE, because string starts with ''The''' );

        result = contains( 'quick' : FOX);
        assert( result :
          'contains() must return TRUE, because string contains ''quick''' );

        result = contains( 'dog.' : FOX);
        assert( result :
          'contains() must return TRUE, because string ends with ''dog.''' );

        // Check ignore case.

        result = contains( 'THE' : FOX);
        assert( result :
          'contains() must return TRUE, because string starts with ''The''' );

        result = contains( 'QUICK' : FOX);
        assert( result :
          'contains() must return TRUE, because string contains ''quick''' );

        result = contains( 'DOG.' : FOX);
        assert( result :
          'contains() must return TRUE, because string ends with ''dog.''' );

      /end-free
     P                 e


     P testCompare...
     P                 b                   export
     D                 pi

     D result          s               n
      /free

        // Check not found.

        result = compare( 'foo bar' : FOX);
        assert( not result :
          'compare() must return FALSE, +
           because string does not match ''foo bar''' );

        result = compare( 'Foo*' : FOX);
        assert( not result :
          'compare() must return FALSE, +
           because string does not start with ''Foo''' );

        result = compare( '*foo-bar*' : FOX);
        assert( not result :
          'compare() must return FALSE, +
           because string does not contain ''foo-bar''' );

        result = compare( '*bar.' : FOX);
        assert( not result :
          'compare() must return FALSE, +
           because string does not end with ''bar.''' );

        // Check.

        result = compare( 'The*' : FOX);
        assert( result :
          'compare() must return TRUE, because string starts with ''The''' );

        result = compare( '*quick*' : FOX);
        assert( result :
          'compare() must return TRUE, because string contains ''quick''' );

        result = compare( '*dog.' : FOX);
        assert( result :
          'compare() must return TRUE, because string ends with ''dog.''' );

        // Check ignore case.

        result = compare( 'THE*' : FOX);
        assert( result :
          'compare() must return TRUE, because string starts with ''The''' );

        result = compare( '*QUICK*' : FOX);
        assert( result :
          'compare() must return TRUE, because string contains ''quick''' );

        result = compare( '*DOG.' : FOX);
        assert( result :
          'compare() must return TRUE, because string ends with ''dog.''' );

        // Check special cases

        result = compare( '*' : FOX);
        assert( result :
          'compare() must return TRUE, because string is not empty');

        result = compare( '*' : '');
        assert( not result :
          'compare() must return FALSE, because string is empty');

        result = compare( '' : '');
        assert( result :
          'compare() must return TRUE, because both strings are empty');

      /end-free
     P                 e

