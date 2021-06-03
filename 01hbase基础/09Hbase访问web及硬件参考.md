# webUI

```sh
http://node1:16010/master-status
```

![1622043779267](E:\HBase\HBase\assets\1622043779267.png)

# 安装目录说明

| 目录名        | 说明                              |
| ------------- | --------------------------------- |
| bin           | 所有hbase相关的命令都在该目录存放 |
| conf          | 所有的hbase配置文件               |
| hbase-webapps | hbase的web ui程序位置             |
| lib           | hbase依赖的java库                 |
| logs          | hbase的日志文件                   |

# **参考硬件配置**

针对大概800TB存储空间的集群中每个Java进程的典型内存配置：

| 进程               | 堆   | 描述                                                        |
| ------------------ | ---- | ----------------------------------------------------------- |
| NameNode           | 8 GB | 每100TB数据或每100W个文件大约占用NameNode堆1GB的内存        |
| SecondaryNameNode  | 8GB  | 在内存中重做主NameNode的EditLog，因此配置需要与NameNode一样 |
| DataNode           | 1GB  | 适度即可                                                    |
| ResourceManager    | 4GB  | 适度即可（注意此处是MapReduce的推荐配置）                   |
| NodeManager        | 2GB  | 适当即可（注意此处是MapReduce的推荐配置）                   |
| HBase HMaster      | 4GB  | 轻量级负载，适当即可                                        |
| HBase RegionServer | 12GB | 大部分可用内存、同时为操作系统缓存、任务进程留下足够的空间  |
| ZooKeeper          | 1GB  | 适度                                                        |

推荐：

- Master机器要运行NameNode、ResourceManager、以及HBase HMaster，推荐24GB左右

- Slave机器需要运行DataNode、NodeManager和HBase RegionServer，推荐24GB（及以上）

- 根据CPU的核数来选择在某个节点上运行的进程数，例如：两个4核CPU=8核，每个Java进程都可以独立占有一个核（推荐：8核CPU）

-  内存不是越多越好，在使用过程中会产生较多碎片，Java堆内存越大， 会导致整理内存需要耗费的时间越大。例如：给RegionServer的堆内存设置为64GB就不是很好的选择，一旦FullGC就会造成较长时间的等待，而等待较长，Master可能就认为该节点已经挂了，然后移除掉该节点