# Hbase的原理

![01-hbase的架构说明](./assets\01-hbase的架构说明.png)

# 系统架构

![1622897862357](./assets\1622897862357.png)

## Client

客户端，例如：发出HBase操作的请求。例如：之前我们编写的Java API代码、以及HBase shell，都是CLient

## Master Server

在HBase的Web UI中，可以查看到Master的位置。

![1622899068968](./assets\1622899068968.png)



- 监控RegionServer

- 处理RegionServer故障转移

- 处理元数据的变更

- 处理region的分配或移除

- 在空闲时间进行数据的负载均衡

- 通过Zookeeper发布自己的位置给客户端

Region Server

![1622899151158](./assets\1622899151158.png)

- 处理分配给它的Region

- 负责存储HBase的实际数据

- 刷新缓存到HDFS

- 维护HLog

- 执行压缩

- 负责处理Region分片

- RegionServer中包含了大量丰富的组件，如下
  - Write-Ahead logs
  -  HFile(StoreFile)
  - Store
  -  MemStore
  -  Region

# 逻辑结构模型

![1622899260070](./assets\1622899260070.png)

## Region

![1622899151158](./assets\1622899151158.png)

## **Store**

- Region按列族垂直划分为「Store」，存储在HDFS在文件中

## MemStore

- MemStore与缓存内存类似

- 当往HBase中写入数据时，首先是写入到MemStore

- 每个列族将有一个MemStore

- 当MemStore存储快满的时候，整个数据将写入到HDFS中的HFile中

## **StoreFile**

- 每当任何数据被写入HBASE时，首先要写入MemStore

- 当MemStore快满时，整个排序的key-value数据将被写入HDFS中的一个新的HFile中

- 写入HFile的操作是连续的，速度非常快

- 物理上存储的是**HFile**

## **WAL**

- WAL全称为Write Ahead Log，它最大的作用就是	故障恢复

- WAL是HBase中提供的一种高并发、持久化的日志保存与回放机制

- 每个业务数据的写入操作（PUT/DELETE/INCR），都会保存在WAL中

- 一旦服务器崩溃，通过回放WAL，就可以实现恢复崩溃之前的数据物理上存储是Hadoop的**Sequence File**