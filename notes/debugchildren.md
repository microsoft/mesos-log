# Debugging Child Processes on Windows

Debugging child processes on Windows is best achieved with Visual Studio.

Note that it's often more efficient to launch the child directly (if you
can determine the environment that the child runs in), but this may not
be possible all of the time.

These instructions are for Visual Studio 2017 Enterprise Edition.

### One-Time Setup for Child Process Debugging

1. Launch Visual Studio 2017
2. Select `Tools -> Extensions & Updates`
    1. Select **Online** on the left hand pane
    2. In the search window, type `Child Process` and hit Return
    3. Find the `Microsoft Child Process Debugging Power Tool`,
       click on that, and download it.
3. When download is complete, exit and relaunch Visual Studio.
4. Select `Tools -> Options`
    1. Select `Projects and Solutions` on the left hand pane
    2. Check `Show Output window when build starts`
    3. Check `Lightweight solution load for all solutions`

### Debug Mesos Child Process

1. Open the Mesos solution file:
    1. Select `File -> Open -> Project/Solution ...`
    2. Navigate to `<Mesos-Root-Directory>/Build`
    3. Select file `Mesos.sln` to open
2. Verify that debug settings are correct:
    1. Select `Debug -> Other Debug Targets -> Child Process Debugging Settings ...`
    2. Check `Enable Child Process Debugging`
    3. From the *Persist settings to:* pulldown, select you can choose how
       and where Visual Studio persists these settings. Unfortunately, both
       choices tend to reset the setting when you rebuild from scratch.
    4. Click **Save** on right hand side of *Child Process Debugging Settings*
       window.
3. Read [Running Unit Tests][] in the Mesos documentation.
4. Select `mesos-tests` as a startup project:
    1. Right clieck `mesos-tests` in the list of projects in the
       *Solution Explorer* window,
    2. Select `Set as StartUp Project` from the pop-up menu.
5. Use standard debugging techniques:
    1. Set breakpoint(s) in the code invoked by `mesos-tests`
    2. Set breakpoint(s) in the child code that will be launched. Note that
       most child code is launched by
       `3rdparty/libprocess/include/process/windows/subprocess.hpp`. If you
       wish to set a breakpoint before launching the process, search for
       *::CreateProcessW*(* in that file.

[Running Unit Tests]: https://github.com/Microsoft/mesos-log/blob/master/notes/development.md#running-unit-tests
