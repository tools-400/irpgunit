# iRPGUnit

Unit Testing for RPG Developers on IBM i.

## Description

iRPGUnit is an open source plugin for RDi 9.5.1.3+. The plug-in provides unit tests for RPG and Cobol (experimental) on IBM i.

iRPGUnit is a fork of the RPGUnit project, providing enhancements and an Eclipse plug-in for running unit test from your IBM Rational Developer for i.

Further information about iRPGUnit are available on the [iRPGUnit Web Site](https://tools-400.github.io/irpgunit/).

Please refer to the [iRPGUnit Version History](<https://tools-400.github.io/irpgunit/files/iRPGUnit for RDi 9.5.1.3+.pdf>) document to find out which operating system release is required for installing the iRPGUnit library.

## Preconditions

iRPGUnit requires OS400 7.5 for the latest features. It can also be installed on 7.4 and 7.3 if the following PTFs have been installed:

**7.4**

* ILE RPG runtime: SI71537
* ILE RPG compiler: SI71536
* SQL Precompile Support UTF-8 stream files: SI70942

**7.3**

* ILE RPG runtime: SI71535
* ILE RPG compiler: SI71534
* SQL Precompile Support UTF-8 stream files: SI70936

If the PTFs have not been installed, the library must be recompiled to disable the latest features, such as assertEqual().

PTFs SI70942 and SI70936 are required for compiling test suites from UTF-8 (Ccsid: 1208) source stream files.

## Features

* Executes iRPGUnit test suites (service programs) from RDi
* Executes iRPGUnit test cases (procedures) from RDi
* Displays Unit Test results in a view.
* Displays Unit Test reports in an editor.
* Opens failed test programs with a simple mouse click.

## Credits

The iRPGUnit plug-in uses a fork of the [RPGUnit](https://sourceforge.net/projects/rpgunit/) library, which was started by Lacton back in September 2006.

Some bugs have been fixed and Mihael Schmidt at [RPG Next Gen](http://www.rpgnextgen.com/http://www.rpgnextgen.com/) added an interface to the IBM Rational Developer for i and started developing the iRPGUnit plug-in. I took over the project and widely enhanced the plug-in. Now the project is supported by Mihael and me.
