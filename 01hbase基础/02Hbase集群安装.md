# 上传安装包

![1622042472597](./assets\1622042472597.png)

# 解压安装包

```sh
cd /export/software
tar -xvzf hbase-2.1.0.tar.gz -C ../server/
```

# 修改HBASE的配置文件

## hbase-env.sh

```sh
cd /export/server/hbase-2.1.0/conf
vim hbase-env.sh
# 第28行
export JAVA_HOME=/export/server/jdk1.8.0_241/
export HBASE_MANAGES_ZK=false
export HBASE_DISABLE_HADOOP_CLASSPATH_LOOKUP="true"
```

## hbase-site.xml

```xml
vim hbase-site.xml
------------------------------
<configuration>
        <!-- HBase数据在HDFS中的存放的路径 -->
        <property>
            <name>hbase.rootdir</name>
            <value>hdfs://node1.it.cn:8020/hbase</value>
        </property>
        <!-- Hbase的运行模式。false是单机模式，true是分布式模式。若为false,Hbase和Zookeeper会运行在同一个JVM里面 -->
        <property>
            <name>hbase.cluster.distributed</name>
            <value>true</value>
        </property>
        <!-- ZooKeeper的地址 -->
        <property>
            <name>hbase.zookeeper.quorum</name>
            <value>node1.it.cn,node2.it.cn,node3.it.cn</value>
        </property>
        <!-- ZooKeeper快照的存储位置 -->
        <property>
            <name>hbase.zookeeper.property.dataDir</name>
            <value>/export/server/apache-zookeeper-3.6.0-bin/data</value>
        </property>
        <!--  V2.1版本，在分布式情况下, 设置为false -->
        <property>
            <name>hbase.unsafe.stream.capability.enforce</name>
            <value>false</value>
        </property>
</configuration>
```

# 配置环境变量

```sh
# 配置Hbase环境变量
vim /etc/profile
export HBASE_HOME=/export/server/hbase-2.1.0
export PATH=$PATH:${HBASE_HOME}/bin:${HBASE_HOME}/sbin

#加载环境变量
source /etc/profile
```

# 复制jar包到lib

```sh
cp $HBASE_HOME/lib/client-facing-thirdparty/htrace-core-3.1.0-incubating.jar $HBASE_HOME/lib/
```

# 修改regionservers文件

```sh
vim regionservers 
node1
node2
node3
```

# 分发安装包与配置文件

```sh
cd /export/server
scp -r hbase-2.1.0/ node2:$PWD
scp -r hbase-2.1.0/ node3:$PWD
scp -r /etc/profile node2:/etc
scp -r /etc/profile node3:/etc

在node2.it.cn和node3.it.cn加载环境变量
source /etc/profile
```

启动Hbase 

```sh
# 启动zk
 zkServer.sh  start
# 查看zk的状态
 zkServer.sh  status

# 在node1上执行格式化指令 (慎用)
hadoop namenode -format


# 启动HDFS
start-dfs.sh

# 启动Yarn
start-yarn.sh

# 启动历史任务服务进程
mr-jobhistory-daemon.sh start historyserver

# 启动hbase
start-hbase.sh

# 全部开启(下面只启动Hadoop而且不启动 mr-jobhistory-daemon.sh start historyserver)

start-all.sh

# 全部关闭
stop-all.sh

停止集群：
stop-dfs.sh
stop-yarn.sh
mr-jobhistory-daemon.sh stop historyservers

```

# 验证Hbase是否启动成功

```sh
# 启动hbase shell客户端
hbase shell
# 输入status
```

结果

```sh
[root@node1 conf]# hbase shell
2021-05-26 23:34:07,933 WARN  [main] util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
HBase Shell
Use "help" to get list of supported commands.
Use "exit" to quit this interactive shell.
Version 2.1.0, re1673bb0bbfea21d6e5dba73e013b09b8b49b89b, Tue Jul 10 17:26:48 CST 2018
Took 0.0021 seconds                                  
hbase(main):001:0> status
1 active master, 0 backup masters, 3 servers, 0 dead, 1.0000 average load
Took 0.4116 seconds                                  
hbase(main):002:0> 
```

