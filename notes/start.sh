#!/bin/bash
# shellcheck shell=bash

# ZooKeeper

start-zookeeper() {
    zookeeper_version=${1:-3.4.10}
    zookeeper=zookeeper-$zookeeper_version
    if [[ ! -e $zookeeper ]]; then
        wget "https://www-eu.apache.org/dist/zookeeper/$zookeeper/$zookeeper.tar.gz"
        tar -xf "$zookeeper.tar.gz"
    fi

    cd "$zookeeper" || exit 1
    if [[ ! -e conf/zoo.cfg ]]; then
        cp conf/zoo_sample.cfg conf/zoo.cfg
    fi

    ./bin/zkServer.sh start-foreground &> log &
}

# Mesos
build-release() {
    mesos_version=${1:-1.4.1}
    mesos=mesos-$mesos_version
    if [[ ! -e $mesos ]]; then
        wget "http://www.apache.org/dist/mesos/$mesos_version/$mesos.tar.gz"
        tar -xf "$mesos.tar.gz"
    fi

    cd "$mesos" || exit 1
    if [[ ! -e build ]]; then
        mkdir build
    fi

    cd build || exit 1
    ../configure --disable-python
    make -j8
}

build-dev() {
    mesos_version=${1:-1.5.x}
    mesos=mesos
    if [[ ! -e $mesos ]]; then
        git clone https://git-wip-us.apache.org/repos/asf/mesos.git
    fi

    cd $mesos || exit 1
    git checkout "$mesos_version"
    if [[ ! -e build ]]; then
        mkdir build
    fi

    cd build || exit 1
    if [[ ! -e CMakeCache.txt ]]; then
        cmake ..  -GNinja -DENABLE_JAVA=ON
        ninja-build mesos-master
        chmod +x bin/*.sh
    fi
}

start-mesos() {
    MESOS_NATIVE_JAVA_LIBRARY=$(pwd)/src/.libs/libmesos.so
    export MESOS_NATIVE_JAVA_LIBRARY

    mkdir -p ~/master_work_dir
    ip=$(hostname -i)
    ./bin/mesos-master.sh --ip="$ip" --work_dir="$HOME/master_work_dir" --zk="zk://$ip:2181/mesos" --quorum=1 &> log &
}

# Marathon

start-marathon() {
    marathon_version=1.5.2
    marathon=marathon-$marathon_version
    if [[ ! -e $marathon.tgz ]]; then
        wget http://downloads.mesosphere.com/marathon/v$marathon_version/$marathon.tgz
        tar -xzf "$marathon.tgz"
    fi

    cd $marathon || exit 1

    ip=$(hostname -i)
    ./bin/marathon --master "zk://$ip:2181/mesos" --zk "zk://$ip:2181/marathon" --checkpoint &> log &
}

start-metronome() {
    metronome=metronome-0.3.3
    cd $metronome || exit 1
    ip=$(hostname -i)
    ./bin/metronome -d -Dmetronome.leader.election.hostname=$ip -Dmetronome.mesos.leader.ui.url=http://$ip:5050 -Dmetronome.mesos.master.url=$ip:5050 &> log &
}

start-cluster() {
    ( start-zookeeper ) &
    ( build-dev ; start-mesos ) &
    ( start-marathon ) &
}
