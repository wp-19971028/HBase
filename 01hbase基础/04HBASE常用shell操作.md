# 创建表

```sh
# 注意：
# create要写成小写
# 一个表可以包含若干个列蔟
# 命令解析：调用hbase提供的ruby脚本的create方法，传递两个字符串参数
# 通过下面链接可以看到每个命令都是一个ruby脚本
# https://github.com/apache/hbase/tree/branch-2.1/hbase-shell/src/main/ruby/shell/commands
create '表名','列蔟名'...

create 'ORDER_INFO','C1'
```

# 查看表

```sh
list
```

# 删除表

```sh
# 禁用表
disable "表名"
# 删除表
drop "表名"
## 说明 如果不禁用表是不允许被删除的

hbase(main):009:0> disable 'ORDER_INFO'
Took 0.5051 seconds                                                                                 
hbase(main):010:0> drop 'ORDER_INFO'
Took 0.2357 seconds                                                                                 
hbase(main):011:0> list
TABLE                                                                                               
0 row(s)
Took 0.0102 seconds                                                                                 
=> []
```

# 往表里加数据

## 需求

| 订单ID | 订单状态 | 支付金额  | 支付方式ID | 用户ID  | 操作时间            | 商品分类 |
| ------ | -------- | --------- | ---------- | ------- | ------------------- | -------- |
| ID     | STATUS   | PAY_MONEY | PAYWAY     | USER_ID | OPERATION_DATE      | CATEGORY |
| 000001 | 已提交   | 4070      | 1          | 4944191 | 2020-04-25 12:09:16 | 手机;    |

## put操作

```sh
# 语法
put '表名','ROWKEY','列蔟名:列名','值'
# 操作
## 建表
create 'ORDER_INFO','C1'
## 插数据
put 'ORDER_INFO','000001','C1:ID','000001'
put 'ORDER_INFO','000001','C1:STATUS','已提交'
put 'ORDER_INFO','000001','C1:PAY_MONEY',4070
put 'ORDER_INFO','000001','C1:PAYWAY',1
put 'ORDER_INFO','000001','C1:USER_ID',4944191
put 'ORDER_INFO','000001','C1:OPERATION_DATE','2020-04-25 12:09:16'
put 'ORDER_INFO','000001','C1:CATEGORY','手机;'

```

# 查询表数据

```sh
# 直接扫描 get '表名','rowkey'
get 'ORDER_INFO','000001'
```

![1622080623052](./assets\1622080623052.png)

```sh
# 显示中文
# 在HBase shell中，如果在数据中出现了一些中文，默认HBase shell中显示出来的是十六进制编码。要想将这些编码显示为中文，我们需要在get命令后添加一个属性：{FORMATTER => 'toString'}
get 'ORDER_INFO','000001', {FORMATTER => 'toString'}
```

![1622081152726](./assets\1622081152726.png)

# **使用put来更新数据**

同样，在HBase中，也是使用put命令来进行数据的更新，语法与之前的添加数据一模一样。

```sh
put 'ORDER_INFO', '000001', 'C1:STATUS', '已付款'
```

![1622081367646](./assets\1622081367646.png)

# 删除数据

> 语法: 
> ​			delete '表名', 'rowkey', '列蔟:列'
>
> 		需求: 请删除掉 ORDER_INFO中  USER_ID这一列的数据
> 			delete 'ORDER_INFO' , '000001', 'C1:USER_ID'
> 	
> 		需求: 删除整行数据: 在hbase的1.x中,此操作是可以执行的, 但是2.x  将此操作使用一个新的命令来替换
> 			delete 'ORDER_INFO' , '000001'
> 	
> 			需要采用下面的命令来解决: 
> 				格式: deleteall '表名','rowkey'
> 	
> 	

```sh
delete 'ORDER_INFO' , '000001', 'C1:USER_ID'
```

![1622081869895](./assets\1622081869895.png)

推荐使用

```sh
deleteall 'ORDER_INFO' , '000001' 'C1:STATUS'
```

![1622081893385](./assets\1622081893385.png)

# 清空表数据

```sh
# truncate "表名"
truncate 'ORDER_INFO'
```

![1622082036824](./assets\1622082036824.png)

# 将数据导入到HBase中

1. 上传数据到任意文件夹
2. 执行文件脚本

![1622082266836](./assets\1622082266836.png)

![1622082365374](./assets\1622082365374.png)



# 统计一个表中有多少条数据

```sh
# 语法
count 'ORDER_INFO'
```

![1622082656095](./assets\1622082656095.png)

# **大量数据的计数统计**

> 当HBase中数据量大时，可以使用HBase中提供的MapReduce程序来进行计数统计。语法如下：
>
> $HBASE_HOME/bin/hbase org.apache.hadoop.hbase.mapreduce.RowCounter '表名'

1. 启动YARN集群
2. 执行命令

```sh
# 启动yarn集群
start-yarn.sh
# 启动history server
mr-jobhistory-daemon.sh start historyserver
# 统计数据
$HBASE_HOME/bin/hbase org.apache.hadoop.hbase.mapreduce.RowCounter 'ORDER_INFO'
```

```sh
2021-05-27 10:34:24,204 INFO  [main] mapreduce.Job: ILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=0
                HDFS: Number of bytes written=0
                HDFS: Number of read operations=0
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=0
        Map-Reduce Framework
                Map input records=66
                Map output records=0
                Input split bytes=201
                Spilled Records=0
                Failed Shuffles=0
                Merged Map outputs=0
                GC time elapsed (ms)=2
                Total committed heap usage (bytes)=93257728
        HBase Counters
                BYTES_IN_REMOTE_RESULTS=0
                BYTES_IN_RESULTS=5616
                MILLIS_BETWEEN_NEXTS=38
                NOT_SERVING_REGION_EXCEPTION=0
                NUM_SCANNER_RESTARTS=0
                NUM_SCAN_RESULTS_STALE=0
                REGIONS_SCANNED=1
                REMOTE_RPC_CALLS=0
                REMOTE_RPC_RETRIES=0
                ROWS_FILTERED=0
                ROWS_SCANNED=66
                RPC_CALLS=1
                RPC_RETRIES=0
        org.apache.hadoop.hbase.mapreduce.RowCounter$RowCounterMapper$Counters
                ROWS=66
        File Input Format Counters 
                Bytes Read=0
        File Output Format Counters 
                Bytes Written=0
```

# 扫描表

```sh
4.9: 扫描表的操作: 
	语法: 
		scan  '表名' [, {FORMATTER => 'toString'} ]

	操作:扫描整个表
		scan  'ORDER_INFO' , {FORMATTER => 'toString'} 
		注意: 此操作 慎用 , 由于在扫描一个大表的时候
		扫描整个表数据, 但是只展示前3条数据: 
		scan 'ORDER_INFO', {LIMIT => 3, FORMATTER => 'toString'}

		扫描整个表数据, 只展示前3条数据, 并且结果中只有 支付状态和支付方式
		scan 'ORDER_INFO', {LIMIT => 3, COLUMNS => ['C1:STATUS', 'C1:PAYWAY'], FORMATTER => 'toString'}

	注意:
		只能使用scan的方式来扫描数据, 都是对整个表的数据扫描

```

# **过滤器**

> 在HBase中，如果要对海量的数据来进行查询，此时基本的操作是比较无力的。此时，需要借助HBase中的高级语法——Filter来进行查询。Filter可以根据列簇、列、版本等条件来对数据进行过滤查询。因为在HBase中，主键、列、版本都是有序存储的，所以借助Filter，可以高效地完成查询。当执行Filter时，HBase会将Filter分发给各个HBase服务器节点来进行查询。

 

> HBase中的过滤器也是基于Java开发的，只不过在Shell中，我们是使用基于JRuby的语法来实现的交互式查询。以下是HBase 2.2的JAVA API文档。

<http://hbase.apache.org/2.2/devapidocs/index.html>

# **HBase中的过滤器**

![1622083666195](./assets\1622083666195.png)

## 过滤器的使用方法

过滤器一般结合scan命令来使用。打开HBase的JAVA API文档。找到RowFilter的构造器说明，我们来看以下，HBase的过滤器该如何使用。

```sh
scan '表名', { Filter => "过滤器(比较运算符, '比较器表达式')” }
```

## 比较运算符

| **比较运算符** | **描述** |
| -------------- | -------- |
| =              | 等于     |
| >              | 大于     |
| >=             | 大于等于 |
| <              | 小于     |
| <=             | 小于等于 |
| !=             | 不等于   |

## 比较器

| **比较器**             | **描述**         |
| ---------------------- | ---------------- |
| BinaryComparator       | 匹配完整字节数组 |
| BinaryPrefixComparator | 匹配字节数组前缀 |
| BitComparator          | 匹配比特位       |
| NullComparator         | 匹配空值         |
| RegexStringComparator  | 匹配正则表达式   |
| SubstringComparator    | 匹配子字符串     |

## 比较表达式

| **比较器**             | **表达式语言缩写**     |
| ---------------------- | ---------------------- |
| BinaryComparator       | binary:值              |
| BinaryPrefixComparator | binaryprefix:值        |
| BitComparator          | bit:值                 |
| NullComparator         | null                   |
| RegexStringComparator  | regexstring:正则表达式 |
| SubstringComparator    | substring:值           |

```sh
#需求一: 使用 RowFilter 查询指定订单ID的数据只查询订单的ID为：02602f66-adc7-40d4-8485-76b5632b5b53 、订单状态以及支付方式
scan 'ORDER_INFO', { FILTER => "RowFilter(=, 'binary:02602f66-adc7-40d4-8485-76b5632b5b53')" ,COLUMNS => ['C1:STATUS', 'C1:PAYWAY'],FORMATTER => 'toString' }

# 需求二: 查询状态为已付款的订单
scan 'ORDER_INFO', { FILTER => "ValueFilter(=, 'binary:已付款')" ,FORMATTER => 'toString' }
#效果: 查询在表中 包含以付款的数据有那些, 结果也只展示对应查询数据的字段内容

scan 'ORDER_INFO', { FILTER => "SingleColumnValueFilter('C1','STATUS',=, 'binary:已付款')" ,FORMATTER => 'toString' }
scan 'ORDER_INFO', { FILTER => "SingleColumnValueExcludeFilter('C1','STATUS',=, 'binary:已付款')" ,FORMATTER => 'toString' }
# 需求三：查询支付方式为1，且金额大于3000的订单 :  组合使用过滤器的方案
scan 'ORDER_INFO', {FILTER => "SingleColumnValueFilter('C1', 'PAYWAY', = , 'binary:1') AND SingleColumnValueFilter('C1', 'PAY_MONEY', > , 'binary:3000')", FORMATTER => 'toString'}

```

# incr的相关的操作:

导入测试数据

```sh
hbase shell /export/software/NEWS_VISIT_CNT.txt 
scan 'NEWS_VISIT_CNT', {LIMIT => 5, FORMATTER => 'toString'}
```



语法: 
​	incr '表名','rowkey','列蔟:列名',累加值（默认累加1）

注意事项: 
​	如果某一列要实现计数功能，必须要使用incr来创建对应的列
​	使用put创建的列是不能实现累加的

添加数据后, 如果查看使用incr 构建的字段的数据: 
​	`get_counter '表名','rowkey','列族:列名'`

具体操作: 

```sh
# 1.获取0000000020这条新闻在01:00-02:00当前的访问次数
get_counter 'NEWS_VISIT_CNT','0000000020_01:00-02:00','C1:CNT' 
# 2.使用incr进行累加
incr 'NEWS_VISIT_CNT','0000000020_01:00-02:00','C1:CNT'  
# 3.再次查案新闻当前的访问次数
get_counter 'NEWS_VISIT_CNT','0000000020_01:00-02:00','C1:CNT'

```

# **更多的操作**

以下连接可以查看到所有HBase中支持的SHELL脚本。

https://learnhbase.wordpress.com/2013/03/02/hbase-shell-commands/

​	