# Deploying Mesos on Windows

These notes document how I managed to launch a task on a Windows agent.
This requires setup of multiple components,
and building Mesos from a patched branch.

## Master setup

Before getting to the Mesos Agent on Windows,
first we need a Mesos master setup,
and a framework that allows deployment of simple applications.
The [Marathon](https://mesosphere.github.io/marathon/) framework is an
easy-to-use web application that allows you to launch a task like `notepad` on an agent.
Depending on the version of Marathon,
it [may not be able](https://github.com/mesosphere/marathon/issues/2950)
to run without [ZooKeeper](https://zookeeper.apache.org/).
Regardless, I set it up with ZooKeeper,
so these instructions will include it.
These are loosely adapted from
[Digital Ocean's guide](https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04).

Marathon, ZooKeeper, and the Mesos master should run on a Linux box,
in my case CentOS 7.

### ZooKeeper

ZooKeeper is just a layer that provides coordination for distributed systems.
If we were running more than one instance of the Mesos master or Marathon,
then ZooKeeper would provide the information necessary to choose the correct
instance among a set of redunant servers.
I am only using one instance each of Marathon and the Mesos master,
but setup ZooKeeper as it is somewhat expected by the other components.
Not using ZooKeeper is an edge case where Marathon and Mesos master
need to be run in standalone mode.

* Download [zookeeper-3.4.9.tar.gz](https://zookeeper.apache.org/releases.html#download)
  from one of the provided mirrors.
* Extract the tarball.
* Deploy the sample configuration.
* Run ZooKeeper.

```sh
wget https://www-us.apache.org/dist/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz
tar -xzf zookeeper-3.4.9.tar.gz
cd zookeeper-3.4.9

cp conf/zoo_sample.cfg conf/zoo.cfg

cd bin
sudo ./zkServer.sh start-foreground
```

The default configuration uses `/tmp/zooKeeper` for storage,
whichi is fine for demonstration purposes.
The default port is `2181`.
Both Mesos and Marathon will connect to ZooKeeper,
so it needs to be running first.

A quick terminology explanation:
a path like `zk://192.0.2.1:2181/name`
indicates a connection to the ZooKeeper instance
at IP address `192.0.2.1`, port `2181`, znode `name`.
According to the [ZooKeeper wiki](https://cwiki.apache.org/confluence/display/ZOOKEEPER/ProjectDescription),
this `znode` is the term used for a view into the ZooKeeper virtual filesystem.
By attaching multiple Mesos master instances to `zk://192.0.2.1:2181/mesos`,
another service (like the Mesos agent or the Marathon framework)
can refer to the collective group of instances by `zk://192.0.2.1:2181/mesos`,
and so ZooKeeper acts as an intermediary so that the other services
do not have to track the Mesos masters individually.

### Mesos master

You probably already have Mesos built from source,
and if so you should run the binaries you built.
If you have not already built Mesos from source,
please see the [Getting Started](https://mesos.apache.org/gettingstarted/)
instructions to install all the prerequisites.

* Download [mesos-1.1.0.tar.gz](https://mesos.apache.org/downloads/) from Apache.
* Extract the tarball.
* Build Mesos.
* Run the Mesos master and attach to ZooKeeper.

```sh
wget http://www.apache.org/dist/mesos/1.1.0/mesos-1.1.0.tar.gz
tar -xzf mesos-1.1.0.tar.gz
cd mesos-1.1.0
mkdir build
cd build
../configure
make

sudo mkdir /var/lib/mesos
sudo ./bin/mesos-master.sh --ip=192.0.2.1 --work_dir=/var/lib/mesos --zk=zk://192.0.2.1:2181/mesos --quorum=1
```

Substitute the `192.0.2.1` with the IP address of the Linux machine
on which these servers are running.
The `--ip` option is the address to which the Mesos master will bind;
the `--work_dir` option is non-optional;
the `--zk` option is the connection information for ZooKeeper;
finally the `--quorum` option is required when using ZooKeeper,
and when using only one master process should be set to `1`.

### Marathon

The last step on the Linux machine is launch Marathon.

* Download [marathon-1.3.5.tgz](https://mesosphere.github.io/marathon/docs/).
* Extract the tarball.
* Run Marathon and attach it to Mesos and ZooKeeper.

```sh
wget http://downloads.mesosphere.com/marathon/v1.3.5/marathon-1.3.5.tgz
tar -xzf marathon-1.3.5.tgz
cd marathon-1.3.5/bin

sudo MESOS_NATIVE_JAVA_LIBRARY=$HOME/mesos-1.1.0/build/src/.libs/libmesos.so \
  ./start --master zk://192.0.2.1:2181/mesos --zk zk://192.0.2.1:2181/marathon
```

Because we did not install Mesos,
Marathon needs `MESOS_NATIVE_JAVA_LIBRARY` set to the location of the
`libmesos.so` library built in the previous step,
so adjust the path accordingly.
Again, substitute `192.0.2.1` with the IP address of the Linux machine.
The `--master` option points Marathon to the ZooKeeper znode of the Mesos master,
allowing Marathon to find Mesos,
and the `--zk` option points Marathon to the ZooKeeper znode of Marathon itself,
allowing multiple Marathon instances to run at the same time
(obviously not required if running standalone, but educational anyway).

## Checking services

At this point, provided your firewall is off or the correct ports are allowed,
you should be able to reach your Mesos instance at http://192.0.2.1:5050/,
and your Marathon instance at http://192.0.2.1:8080.

## Agent setup

Running tasks or containers with the Windows Agent requires
Windows Server 2016, and a build with Daniel Pravat's patches.
Again, see the [Getting Started](https://mesos.apache.org/gettingstarted/)
guide for prerequisites.

```powershell
cd C:\
git clone -b reviewwork https://github.com/dpravat/mesos.git
cd mesos
mkdir build
cd build
cmake .. -G "Visual Studio 14 2015 Win64" -DENABLE_LIBEVENT=1
msbuild Mesos.sln /p:PreferredToolArchitecture=x64

mkdir C:\w
cd src
.\mesos-agent.exe --master=zk://192.0.2.1:2181/mesos --work_dir=C:\w --runtime_dir=C:\w  --launcher_dir=C:\mesos\build\src --isolation=windows/cpu,filesystem/windows --ip=192.0.2.2
```

There are several important points here:

* We built from Daniel's `reviewwork` branch,
  which has the patches to (theoretically) enable tasks and containers.
* We set the `work_dir` and `runtime_dir` to `C:\w`
  because we quickly run into the 260 character path limit otherwise.
* We set the `--master` to the `mesos` znode.
* We set the `--ip` to the Windows machine's IP address

Now go to Marathon at http://192.0.2.1:8080 and launch a task:

* Click "Applications" in the top banner
* Click "Create Application" in the top right corner
* Use a *single character* for the ID (e.g. `p`) (again, Windows path limitations)
* Enter a simple command for "command" (e.g. `ping google.com`)
* Click "Create Application" at the bottom left of the popup box

It should start scheduling the task on the Windows agent.
Check that the Windows agent is connected by listing the agents
at your Mesos interface http://192.0.2.1:5050/#/agents.

Unfortunately at this point, the `mesos-containerizer` crashes after launch;
but you should see the agent attempt to start the task,
and then report `TASK_FAILED`.
