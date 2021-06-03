# 表结构

![1622076359685](./assets\1622076359685.png)

# 术语

## 表table

- HBase中数据都是以表形式来组织的

- HBase中的表由多个行组成
- 一个表中可以有十亿上的数据, 上百万个列

## 行（row）

- HBASE中的行由一个rowkey（行键）和一个或多个列组成，列的值与rowkey、列相关联

- 行在存储时按行键按字典顺序排序

- 行键的设计非常重要，尽量让相关的行存储在一起

- 例如：存储网站域。如行键是域，则应该将域名反转后存储(org.apache.www、org.apache.mail、org.apache.jira)。这样，所有Apache域都在表中存储在一起，而不是根据子域的第一个字母展开
- 行键   相当于是表中主键, 只不过在hbase中 称为rowkey
  ​		rowkey中数据默认会按照字典序的升序进行排序操作

 

## 列（Column）

- HBASE中的列由列族（Column Family）和列限定符（Column Qualifier）组成

- 表示如下——列族名:列限定符名。例如：C1:USER_ID、C1:SEX

#### 列族（Column Family）

![1622076713288](./assets\1622076713288.png)

- 出于性能原因，列族将一组列及其值组织在一起

- 每个列族都有一组存储属性，例如：

  - 是否应该缓存在内存中

  - 数据如何被压缩或行键如何编码等

- 表中的每一行都有相同的列族，但在列族中不存储任何内容

- 所有的列族的数据全部都存储在一块（文件系统HDFS）

- HBase官方建议所有的列蔟保持一样的列，并且将同一类的列放在一个列蔟中

- column family : 列族  理解为RDBMS中一个列  , 一个列族下可以有多个列名(上百万个)
  ​		列族在构建表的时候, 越少越好, 能用解决 不用二个

#### **列标识符（Column Qualifier）**

- 列族中包含一个个的列限定符，这样可以为存储的数据提供索引

- 列族在创建表的时候是固定的，但列限定符是不作限制的

- 不同的行可能会存在不同的列标识符

- 列名   一个列名必须属于某一个列族, 而一个列族下可以有多个列名
  列名一般在添加数据的时候, 动态指定, 不需要构建表的时候来指定

## 单元格（Cell）

- 单元格是行、列系列和列限定符的组合

- 包含一个值和一个时间戳（表示该值的版本）

- 单元格中的内容是以二进制存储的
- 如何确定一个唯一的单元格呢?   rowkey + 列族 + 列名 + 列值

| ROW     | COLUMN+CELL                                                  |
| ------- | ------------------------------------------------------------ |
| 1250995 | column=C1:ADDRESS, **timestamp**=1588591604729, value=\xC9\xBD\xCE\xF7\xCA |
| 1250995 | column=C1:LATEST_DATE, **timestamp**=1588591604729, value=2019-03-28 |
| 1250995 | column=C1:NAME, **timestamp**=1588591604729, value=\xB7\xBD\xBA\xC6\xD0\xF9 |
| 1250995 | column=C1:NUM_CURRENT, **timestamp**=1588591604729, value=398.5 |
| 1250995 | column=C1:NUM_PREVIOUS, **timestamp**=1588591604729, value=379.5 |
| 1250995 | column=C1:NUM_USEAGE, **timestamp**=1588591604729, value=19  |
| 1250995 | column=C1:PAY_DATE, **timestamp**=1588591604729, value=2019-02-26 |
| 1250995 | column=C1:RECORD_DATE, **timestamp**=1588591604729, value=2019-02-11 |
| 1250995 | column=C1:SEX, **timestamp**=1588591604729, value=\xC5\xAE   |
| 1250995 | column=C1:TOTAL_MONEY, **timestamp**=1588591604729, value=114 |

## timeStamp: 时间戳 

- 默认情况下, 添加一条数据的时候, 会将当前时间设置为添加数据的时间值

## versionNum : 版本号

- 版本号, 表示是否要记录某一个单元格历史版本数据, 默认情况 version版本号1 , 表示只记录当前版本不记录历史版本

## **概念模型**

| **Row Key**       | **Time Stamp** | **ColumnFamily** **contents** | **ColumnFamily** **anchor**   | **ColumnFamily** **people** |
| ----------------- | -------------- | ----------------------------- | ----------------------------- | --------------------------- |
| "com.cnn.www"     | t9             |                               | anchor:cnnsi.com = "CNN"      |                             |
| "com.cnn.www"     | t8             |                               | anchor:my.look.ca = "CNN.com" |                             |
| "com.cnn.www"     | t6             | contents:html = "<html>…"     |                               |                             |
| "com.cnn.www"     | t5             | contents:html = "<html>…"     |                               |                             |
| "com.cnn.www"     | t3             | contents:html = "<html>…"     |                               |                             |
| "com.example.www" | t5             | contents:html = "<html>…"     |                               | people:author = "John Doe"  |

- “com.cnn.www”这一行anchor列族两个列（anchor:cssnsi.com、anchor:my.look.ca）、contents列族有个1个列（html）

- “com.cnn.www”在HBase中有 t3、t5、t6、t8、t9 5个版本的数据

- HBase中如果某一行的列被更新的，那么最新的数据会排在最前面，换句话说同一个rowkey的数据是按照倒序排序的