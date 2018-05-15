      // =====================================================================
      //
      // Unit tests for STRING.
      //
      // =====================================================================
      //   >>PRE-COMPILER<<
      //     >>CRTCMD<<  RUCRTTST   TSTPGM(&LI/&OB) SRCFILE(&SF);
      //     >>COMPILE<<
      //       >>PARM<< DBGVIEW(*LIST);
      //     >>END-COMPILE<<
      //     >>EXECUTE<<
      //   >>END-PRE-COMPILER<<
      // =====================================================================

     H NoMain Option(*SrcStmt) BndDir('QC2LE')


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


      //----------------------------------------------------------------------
      //   Imported Procedures
      //----------------------------------------------------------------------

      /copy RPGUNIT1,TESTCASE
      /copy RPGUNITY1,ASSERT
      /copy RPGUNITY1,STRING
      /copy RPGUNITY1,TEMPLATES


      //----------------------------------------------------------------------
      //   Private Procedure Prototypes
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Global Variables
      //----------------------------------------------------------------------

      //----------------------------------------------------------------------
      //   Set up & Tear down
      //----------------------------------------------------------------------


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

