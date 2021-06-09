> 考虑关于HBase集群的一个问题，在当前的HBase集群中，只有一个Master，一旦Master出现故障，将会导致HBase不再可用。所以，在实际的生产环境中，是非常有必要搭建一个高可用的HBase集群的。

## HBase高可用简介

> HBase的高可用配置其实就是HMaster的高可用。要搭建HBase的高可用，只需要再选择一个节点作为HMaster，在HBase的conf目录下创建文件backup-masters，然后再backup-masters添加备份Master的记录。一条记录代表一个backup master，可以在文件配置多个记录。

## 搭建Hbase高可用

1. 在hbase的conf文件夹创建backup-masters 文件

   ```sh
   cd /export/server/hbase-2.1.0/conf
   touch backup-masters
   ```

2. 将node2和node3添加到该文件中

   ```sh
   vim backup-masters
   
   ------------------
   node2.it.cn
   node3.it.cn
   ```

3.  将backup-masters文件分发到所有的服务器节点中

```sh
scp backup-masters node2.it.cn:$PWD
scp backup-masters node3.it.cn:$PWD
```

4.  重新启动hbase

```sh
stop-hbase.sh
start-hbase.sh
```

5. 查看webui，检查Backup Masters中是否有node2.it.cn、node3.it.cn

[http://node1.it.cn:16010/master-status](http://node1.it.cn:16010/master-status)

6. 尝试杀掉node1.it.cn节点上的master

```sh
kill -9  HMaster进程id
```

7.  访问[http://node2.it.cn:16010](http://node1.it.cn:16010/master-status)和<http://node3.it.cn:16010>，观察是否选举了新的Master

