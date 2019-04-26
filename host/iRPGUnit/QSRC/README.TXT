   ===   RPGUnit   ===

RPGUnit is a regression testing framework similar to JUnit
(http://www.junit.org/). Instead of targetting the Java language, it focuses
on RPG ILE, a language found mainly on the iSeries (a.k.a. AS/400) platform.

In JUnit, developpers write one class per test suite and one method per test
case. In RPGUnit, they write one NoMain RPG module per test suite and one
exported procedure per test case. After compiling the test suite as an ILE
service program, the framework can run all test cases and produce a test run
report, indicating any failure or error found.

RPGUnit is RPG-centric in three ways.
1. The unit test are written in RPG. Thus, RPG programmers can write their
own automated unit tests. Yet, any ILE language can also be used.
2. The framework is meant to test programs written in RPG. Yet, any iSeries
program can be tested, regardless of the implementation language.
3. The framework itself is written in RPG. This is an application of the 'eat
your own dog food' slogan.

Author: Lacton (lacton (at) users.sourceforge.net)
Date Written: 2006-09-08
