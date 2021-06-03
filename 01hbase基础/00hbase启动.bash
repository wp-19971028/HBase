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

# 启动hbase shell客户端
hbase shell
# 输入status

# 全部开启(下面只启动Hadoop而且不启动 mr-jobhistory-daemon.sh start historyserver)

start-all.sh

# 全部关闭
stop-all.sh

停止集群：
stop-dfs.sh
stop-yarn.sh
mr-jobhistory-daemon.sh stop historyservers
