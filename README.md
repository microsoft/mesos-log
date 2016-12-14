# Work log for Microsoft's Mesos core team

This repository is meant to help coordinate Microsoft's Mesos core team. It serves as a reference for useful resources (useful for onboarding, _etc_.), as well as a log of progress and plans week-to-week.

## Quick links

* [Issue Dashboard][issues]
* [Mesos on Windows Epic][windows epic]
* [CMake Build System Epic][cmake epic]
* [Windows Agent Tests Epic][agent tests epic]
* [Review Board][]
* [Slack][]

[issues]: https://issues.apache.org/jira/secure/Dashboard.jspa?selectPageId=12327654#
[windows epic]: https://issues.apache.org/jira/browse/MESOS-3094
[cmake epic]: https://issues.apache.org/jira/browse/MESOS-898
[agent tests epic]: https://issues.apache.org/jira/browse/MESOS-6695
[review board]: https://reviews.apache.org/dashboard/
[slack]: https://mesos.slack.com/messages/windows/

## Onboarding Resources

Onboarding usually consists of two steps: (1) getting all the things you need to contribute (including accounts on community-hosted bug trackers, and stuff), and (2) getting a bug and submitting your first patch. Here we discuss both of these.

### Getting Started

New developers should:

* Build Mesos from source, using the directions in the [Getting Started](https://mesos.apache.org/gettingstarted/) guide.
  * NOTE: because Windows doesn't have a package manager, our build system will download some of the Mesos dependencies from a canonical resource [here](https://github.com/3rdparty/mesos-3rdparty). If you accidentally trigger a rebuild of one of those, CMake may try to download those repositories, which can be particularly annoying if you're somewhere without an Internet connection. To prevent this, you should point CMake at a local copy of htis repository: just `git clone` that URL, and configure pass the flag `-D3RDPARTY_DEPENDENCIES=[path to repo]`, and CMake will get the tarballs from there instead.
* Create community accounts with directions [here](http://mesos.apache.org/community/). Specifically:
  * Sign up for the dev@ and user@ lists.
  * Create an account on the Mesos Slack, join the #windows and #cmake channels. (Post general dev questions to #dev rather than #general, as #general is more for user questions.) Ping me (@hausdorff) when you get there if you want a friendly face.
  * Create accounts with the Mesos instances of JIRA (bug tracking), and Review Board (code reviews).
  * NOTE: If you want to retain these emails in the event you eventually leave Microsoft, you might consider using your personal email rather than your @microsoft email. Since it's all open source anyway, these emails won't contain business-sensitive information.

### Submitting a patch

Mesos has a reasonably complete [submission guide](http://mesos.apache.org/documentation/latest/submitting-a-patch/), so you should read that to learn about the submission process. Generally, if you're planning on helping Microsoft's planned work roadmap, then the process is a bit more streamlined than if you were starting from scratch:

* After you join the Mesos Slack (see the "Getting Started" section, ping @hausdorff to get a starter bug. Probably you will add yourself to the [contributors.yaml](https://github.com/apache/mesos/blob/master/docs/contributors.yaml) to start.
  * You can then follow the guide above to learn how to push the patch to RB. Be sure to attach `hausdorff` to the review.
  * Particularly worth noting is the Mesos [C++ style guide](http://mesos.apache.org/documentation/latest/c++-style-guide/), which is lightly adapted from Google's C++ style guide. Mesos as a project is pretty strict about maintaining this style, so it's important to make an extra effort to follow it.
  * You should be aware that all reviews are public, so if you need to discuss something business-sensitive, it's best to not do that in a code review.
* After you submit your patch, it will be reviewed and if that goes well, a committer will eventually commit the work to the Apache `master` branch.

## Tracking work

Mesos uses JIRA to track work. We divide work tracking into two big tasks: maintaining a comprehsive backlog of work that needs to be done at some point, and maintaining a list of issues we're currently working on. Here we describe both of these things.

### The Comprehensive List of Work

Currently, Microsoft's work in aggregate mostly falls into 3 buckets:

* **Work done to make Windows support production-worthy in Mesos core.** The list of outstanding known issues is [here][windows epic]. This list is meant to be comprehensive, but in practice it is hard to keep up, so some issues have gotten stale, and others are missing.
  * So far, the major work that needs to be done is: (1) remove the dependency on APIs that do not support long paths, (2) add Agent authentication, and (3) complete the work to support Windows Container.
* **Work done to light up all the Agent tests on Windows.** The list of critical-path tests to port is [here][agent tests epic]. Historically, this has been hard because we had to make the Master work on Windows in order to be able to even run Agent tests. Now that that's done, our remaining work focuses mostly on the tests themselves.
  * Beyond that, there are many more-optional tests we will need to prioritze and also light up.
* **Work done to make the build system cross-platform.** The list of known issues is [here][cmake epic]. Historically Mesos has relied on an autotools-based build system. This obviously won't work for Windows, so part of the Windows effort involved rewriting the build system in CMake, so that it can work on Windows. This is pretty far along, and once we are done, we expect to deprecate the autotools solution.

### Current Work

A dashboard of issues we are planning to work on over the next month or two are [here][issues]. As of now (2016/12/09), this work is mostly devoted to completing points (2) and (3) from above. In particular, this dashboard is meant to track progress on two important goals:

* To make all critical tests build and pass on Windows, and to have this fully integrated into official Mesos CI solutions.
* To begin to deprecate the autotools-based build solution, and replace it with our new CMake system.
