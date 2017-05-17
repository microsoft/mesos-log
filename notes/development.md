Windows Development
===================

This document is just a set of notes from my experience onboarding with Mesos development for Windows.

APIs
----

We are targetting Microsoft Nano Server.
Specifically, this means we are restricted to the set of Windows APIs available on Nano,
[Nano Server APIs](https://msdn.microsoft.com/en-us/library/mt588480(v=vs.85).aspx).
An example of an *excluded and unavailable* set of APIs is `Shell32.dll` AKA `<shlobj.h>`.

Running Unit Tests
------------------

Assuming you have the Visual Studio solution for Mesos open,
find the project `mesos-tests` in the Solution Explorer.
Right-click it and choose "Set as StartUp Project."
This will cause the normal build and debugging commands
(i.e. `F5` or the "green arrow") to build and run the unit tests.

By default, this will run all of the unit tests.
Because the agent (and thus many of the tests) attempts to make symbolic links,
Visual Studio needs to be opened as an administrator
(this may change in the future if Windows stops requiring permissions for symlinks).

To run a subset of tests,
you need to run the `mesos-tests` runner with the flag
`--gtest_filter="TestCaseName.TestName"`.
(See [GoogleTest](https://github.com/google/googletest/blob/master/googletest/docs/AdvancedGuide.md#running-a-subset-of-the-tests).)
You _can_ do this on the command line,
but you can also edit the `mesos-tests` project properties,
under the "Debugging" section,
and add this argument to "Command Arguments."
This will now run the specific test when you press `F5` (or the green arrow).
Note that parameterized unit tests will have longer names,
these can be run using wildcards,
e.g. `--gtest_filter="*DefaultExecutorTest*.*"`.

Visual Studio will close the console window in which the tests were ran,
but you can add a break point to the last line of the `main` function to keep it open.

When running unit tests, you will want to set in your environment `GLOV_v=3` ,
and pass `--verbose` to the test runner. This will enable all the log output.

Handles
-------

The Windows API is flawed and has multiple invalide semantic values for the `HANDLE` type,
i.e. some APIs return `-1` or `INVALID_HANDLE_VALUE`, and other APIs return `nullptr`.
It is simply [inconsistent](https://blogs.msdn.microsoft.com/oldnewthing/20040302-00/?p=40443),
and so developers must take extra caution when checking handles returned from the Windows APIs,
double check against the documentation which value will indicate it is invalid.

Using raw handles (or indeed raw pointers anywhere) in C++ is treachorous.
Mesos has a `SafeHandle` class which should be used immediately when obtaining a `HANDLE`
from a Windows API, with the deleter likely set to `::CloseHandle`.

TODO(andschwa):
* examples
* hashset/hashmap
* try/option and operators
* style
