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
      //                      &LI/PGMMSG    +
      //                      );
      //     >>PARM<<  COPTION(*EVENTF);
      //   >>END-IMPORTANT<<
      //   >>CMD<<     CMPMOD MODULE(&LI/STRING   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>CMD<<     CMPMOD MODULE(&LI/PGMMSG   ) SRCFILE(&SL/QSRC) DBGVIEW(*LIST);
      //   >>EXECUTE<<
      // >>END-PRE-COMPILER<<
      // ==========================================================================

     H NoMain Option(*SrcStmt)
      // The following control options are required
      // for test case testParseNum().
     H ExprOpts(*RESDECPOS) DecEdit('0,')


      //----------------------------------------------------------------------
      //   Exported Procedures
      //----------------------------------------------------------------------

     D setupSuite...
     D                 pr                  extproc('setupSuite')

     D testUCase...
     D                 pr                  extproc('testUCase')

     D testLeftStr...
     D                 pr                  extproc('testLeftStr')

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

     D testParseNum...
     D                 pr                  extproc('testParseNum')


      //----------------------------------------------------------------------
      //   Internal Procedures
      //----------------------------------------------------------------------

     D toJobFmt...
     D                 pr            96a   varying
     D                                     extproc('toJobFmt')
     D  i_value                      96a   const varying

     D getDecFmt...
     D                 pr             1a   extproc('getDecFmt')

      //----------------------------------------------------------------------
      //   Global Constants
      //----------------------------------------------------------------------

     D FOX             c                    'The quick brown fox jumps over +
     D                                      the lazy dog.'

      //----------------------------------------------------------------------
      //   Test Suite Status
      //----------------------------------------------------------------------

     D g_status        ds                  qualified
     D  decFmt                        1a

      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /include qinclude,ASSERT
      /include qinclude,STRING
      /include qinclude,TEMPLATES
      /include qinclude,ERRORCODE

      /include qsysinc,QUSRJOBI



      //----------------------------------------------------------------------
      //   Setup & Tear Down
      //----------------------------------------------------------------------

     P setupSuite...
     P                 b                   export
     D                 pi

        g_status.decFmt = getDecFmt();

     P                 e

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
           errMsgInfo = getMonitoredMessage(*on);
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

      //----------------------------------------------------------------------
      //   Test case of: parseNum()
      //----------------------------------------------------------------------
     P testParseNum...
     P                 b                   export
     D                 pi

     D MAX_VALUE_0     c                   '9+
     D                                      999999999999999999999+
     D                                      999999999999999999999,+
     D                                      99999999999999999999'
     D MAX_VALUE       c                   '9.+
     D                                      999.999.999.999.999.999.999.+
     D                                      999.999.999.999.999.999.999,+
     D                                      99999999999999999999'
     D input           s             96a   varying
     D actual          s             63S20
     D expected        s             63S20
     D msgInfo         ds                  likeds(MsgInfo_t)
      /free

       input = '';
       actual = parseNum(input);
       expected = 0;
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt(MAX_VALUE);
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20);
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt(MAX_VALUE) + '-';
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20) * -1;
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = '-' + toJobFmt(MAX_VALUE);
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20) * -1;
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt(MAX_VALUE) + 'CR';
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20) * -1;
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt('12.34.56,789'); // Unusual digit groups
       actual = parseNum(input);
       expected = %dec('123456,789': 63: 20);
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt('.12.34.56,789'); // Unusual digit groups
       actual = parseNum(input);
       expected = %dec('123456,789': 63: 20);
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt('   ' + MAX_VALUE); // Leading blanks (positive value)
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20);
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt(' -' + MAX_VALUE); // Leading blanks (negative value)
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20) * -1;
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt(MAX_VALUE + '   '); // Trailing blanks (positive value)
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20);
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt(MAX_VALUE + '- '); // Trailing blanks (negative value)
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20) * -1;
       assert(actual = expected
              : 'Error parsing: ' + input);

       input = toJobFmt(MAX_VALUE + 'CR '); // Trailing blanks (negative value)
       actual = parseNum(input);
       expected = %dec(MAX_VALUE_0: 63: 20) * -1;
       assert(actual = expected
              : 'Error parsing: ' + input);

       monitor;
         input = toJobFmt('- 123,456'); // Blanks between sign and digits
         actual = parseNum(input);
         fail('Expected format error: blanks between sign and digits');
       on-error;
         msgInfo = getMonitoredMessage(*on);
         assert(msgInfo.id = 'CPF9897': 'Expected msg id was: CPF9897');
       endmon;

       monitor;
         input = toJobFmt('123,456 CR'); // Blanks between sign and digits
         actual = parseNum(input);
         fail('Expected format error: blanks between sign and digits');
       on-error;
         msgInfo = getMonitoredMessage(*on);
         assert(msgInfo.id = 'CPF9897': 'Expected msg id was: CPF9897');
       endmon;

       monitor;
         input = toJobFmt('--123,456'); // duplicate sign
         actual = parseNum(input);
         fail('Expected format error: duplicate sign');
       on-error;
         msgInfo = getMonitoredMessage(*on);
         assert(msgInfo.id = 'CPF9897': 'Expected msg id was: CPF9897');
       endmon;

       monitor;
         input = toJobFmt('-1-123,456'); // duplicate sign
         actual = parseNum(input);
         fail('Expected format error: duplicate sign');
       on-error;
         msgInfo = getMonitoredMessage(*on);
         assert(msgInfo.id = 'CPF9897': 'Expected msg id was: CPF9897');
       endmon;

       monitor;
         input = toJobFmt('-123,456CR'); // duplicate sign
         actual = parseNum(input);
         fail('Expected format error: duplicate sign');
       on-error;
         msgInfo = getMonitoredMessage(*on);
         assert(msgInfo.id = 'CPF9897': 'Expected msg id was: CPF9897');
       endmon;

       monitor;
         input = toJobFmt('CR'); // sign without digits
         actual = parseNum(input);
         fail('Expected format error: sign without digits');
       on-error;
         msgInfo = getMonitoredMessage(*on);
         assert(msgInfo.id = 'CPF9897': 'Expected msg id was: CPF9897');
       endmon;

       monitor;
         input = toJobFmt('12a3,456CR'); // invalid characters
         actual = parseNum(input);
         fail('Expected format error: invalid character');
       on-error;
         msgInfo = getMonitoredMessage(*on);
         assert(msgInfo.id = 'CPF9897': 'Expected msg id was: CPF9897');
       endmon;

       monitor;
         input = toJobFmt('12a3,456CR12'); // invalid characters following CR
         actual = parseNum(input);
         fail('Expected format error: invalid character');
       on-error;
         msgInfo = getMonitoredMessage(*on);
         assert(msgInfo.id = 'CPF9897': 'Expected msg id was: CPF9897');
       endmon;


      /end-free
     P                 e

      //----------------------------------------------------------------------
      //   Convert decimal string to job decimal format.
      //   Input string must be in decimal format 'J'.
      //----------------------------------------------------------------------
     P toJobFmt...
     P                 b                   export
     D                 pi            96a   varying
     D  i_value                      96a   const varying

     D rtnValue        s             96a   varying
      /free

       // Info: Input value must be in format 'J'.
       //       A comma (,) is used for the decimal format.

       if (i_value = '');
         return i_value;
       endif;

       if (g_status.decFmt = '');
         rtnValue = %xlate(',': '/': i_value);
         rtnValue = %xlate('.': ',': rtnValue);
         rtnValue = %xlate('/': '.': rtnValue);
         return rtnValue;
       else;
         return i_value;
       endif;

      /end-free
     P                 e

      //----------------------------------------------------------------------
      //   Get job decimal format.
      //----------------------------------------------------------------------
     P getDecFmt...
     P                 b                   export
     D                 pi             1a

     D jobi0400        ds                  likeds(jobi0400_t) inz

     D percolateErrors...
     D                 ds                  likeds(percolateErrors_t)
     D                                     inz(*likeds)
      /free

       QUSRJOBI(jobi0400: %size(jobi0400): 'JOBI0400'
                : '*': '': percolateErrors);
       return jobi0400.decFmt;

      /end-free
     P                 e

