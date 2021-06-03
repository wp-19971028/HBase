# 环境搭建

1. 创建maven 项目
2. 导入maven依赖
3. 配置相关配置

![1622103197621](./assets\1622103197621.png)

core-site.xml 和hadoop集群的配置要一样

```xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License. See accompanying LICENSE file.
-->

<!-- Put site-specific property overrides in this file. -->

<configuration>
<!-- 用于设置Hadoop的文件系统，由URI指定 -->
	 <property>
		    <name>fs.defaultFS</name>
		    <value>hdfs://node1:8020</value>
	 </property>
<!-- 配置Hadoop存储数据目录,默认/tmp/hadoop-${user.name} -->
	 <property>
		   <name>hadoop.tmp.dir</name>
		   <value>/export/server/hadoop-2.7.5/hadoopDatas/tempDatas</value>
	</property>

	<!--  缓冲区大小，实际工作中根据服务器性能动态调整: 根据自己的虚拟机的内存大小进行配置即可, 不要小于1GB, 最高配置为 4gb  -->
	 <property>
		   <name>io.file.buffer.size</name>
		   <value>4096</value>
	 </property>

	<!--  开启hdfs的垃圾桶机制，删除掉的数据可以从垃圾桶中回收，单位分钟 -->
	 <property>
		   <name>fs.trash.interval</name>
		   <value>10080</value>
	 </property>
</configuration>

```

hbase-site.xml 和hbase里的配置要一样

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<!--
/**
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
-->

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

log4j.properties

```properties
log4j.rootLogger=INFO,stdout
log4j.appender.stdout=org.apache.log4j.ConsoleAppender 
log4j.appender.stdout.layout=org.apache.log4j.PatternLayout 
log4j.appender.stdout.layout.ConversionPattern=%5p - %m%n
```

# 查看数据库下有什么表

```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Admin;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.IOException;


// 说明: 此类用于java操作hbase相关测试类
public class TableAmdinTest {

    private Configuration configuration;
    private Connection connection;
    private Admin admin;

    @BeforeTest
    public void beforeTest() throws IOException {
        //1. 获取hbase的连接对象:
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
        //2. 获取执行操作的相关管理对象:  admin对象(对表的操作)  和  table对象 (对表数据的操作)
        admin = connection.getAdmin();
    }
    // 执行相关操作
    @Test
    public void mainTest() throws IOException {
        //获取数据库下的所有表 命令 list
        TableName[] tableNames = admin.listTableNames();
        // 分析源码 ctrl + alt +b
        for (TableName t: tableNames) {
            System.out.println(t.toString());
        }

    }
    //4. 释放资源
    @AfterTest
    public void afterTest() throws IOException {
        admin.close();
        connection.close();
    }
}


```

# 创建一个表

```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.IOException;

public class Create_table {

    private Configuration configuration;
    private Connection connection;
    private Admin admin;

    @BeforeTest
    public void beforeTest() throws IOException {
        //1. 获取hbase的连接对象:
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
        //2. 获取执行操作的相关管理对象:  admin对象(对表的操作)  和  table对象 (对表数据的操作)
        admin = connection.getAdmin();
    }
    // 执行相关操作 创建表
    @Test
    public void mainTest() throws IOException {
        // 定义表名
        String TABLE_NAME = "WATER_IBLL";
        //定义簇祖名
        String COLUMN_FAMILY = "C1";

        // 判断表是否存在
        if(admin.tableExists(TableName.valueOf(TABLE_NAME))){
            return;
        }
        // 构建表的描述构建器
        TableDescriptorBuilder tableDescriptorBuilder = TableDescriptorBuilder.newBuilder(TableName.valueOf(TABLE_NAME));
        // 构建列簇描述构建器
        ColumnFamilyDescriptorBuilder columnFamilyDescriptorBuilder = ColumnFamilyDescriptorBuilder.newBuilder(Bytes.toBytes(COLUMN_FAMILY));

        // 构建列簇描述器
        ColumnFamilyDescriptor columnFamilyDescriptor = columnFamilyDescriptorBuilder.build();
        // 给表添加列簇
        tableDescriptorBuilder.setColumnFamily(columnFamilyDescriptor);
        // 构建表描述
        TableDescriptor tableDescriptor = tableDescriptorBuilder.build();
        // 创建表
        admin.createTable(tableDescriptor);


    }
    //4. 释放资源
    @AfterTest
    public void afterTest() throws IOException {
        admin.close();
        connection.close();
    }
}



```

# 删除表

~~~java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.IOException;

public class drop_table {

    private Configuration configuration;
    private Connection connection;
    private Admin admin;

    @BeforeTest
    public void beforeTest() throws IOException {
        //1. 获取hbase的连接对象:
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
        //2. 获取执行操作的相关管理对象:  admin对象(对表的操作)  和  table对象 (对表数据的操作)
        admin = connection.getAdmin();
    }
    // 执行相关操作 创建表
    @Test
    public void mainTest() throws IOException {
        // 定义表名
        TableName tableName = TableName.valueOf("WATER_BILL");
        //判断表是否存在
        if(admin.tableExists(tableName)){
            // 2. 禁用表
            admin.disableTable(tableName);
            // 3. 删除表
            admin.deleteTable(tableName);
        }
    }
    //4. 释放资源
    @AfterTest
    public void afterTest() throws IOException {
        admin.close();
        connection.close();
    }
}


~~~

# 添加表数据

```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.IOException;

public class put_data {

    private Configuration configuration;
    private Connection connection;
    private Admin admin;

    @BeforeTest
    public void beforeTest() throws IOException {
        //1. 获取hbase的连接对象:
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
        //2. 获取执行操作的相关管理对象:  admin对象(对表的操作)  和  table对象 (对表数据的操作)
        admin = connection.getAdmin();
    }
    // 执行相关操作 插入姓名列数据
    @Test
    public void putTest() throws IOException {
        // 获取Hbase连接获取Htable
        TableName writeBilltableName = TableName.valueOf("WATER_BILL");
        Table writerBillTable = connection.getTable(writeBilltableName);

        // 构建ROWKEY ,列簇名,列名
        String rowkey = "4944191";
        String cfName = "C1";
        String colName = "NAME";

        // 构建put对象 (对应put命令)
        Put put = new Put(Bytes.toBytes(rowkey));
        // 添加姓名
        put.addColumn(
                Bytes.toBytes(cfName), // 添加列簇名
                Bytes.toBytes(colName), // 添加列名
                Bytes.toBytes("登卫红") // 添加对应列名下的值
        );
        // 对Htable表对象执行put操作
        writerBillTable.put(put);
        // 关闭表
        writerBillTable.close();

    }
    //4. 释放资源
    @AfterTest
    public void afterTest() throws IOException {
        admin.close();
        connection.close();
    }
}
```

# 添加多条数据

| **列名**     | **说明**       | **值**                       |
| ------------ | -------------- | ---------------------------- |
| ADDRESS      | 用户地址       | 贵州省铜仁市德江县7单元267室 |
| SEX          | 性别           | 男                           |
| PAY_DATE     | 缴费时间       | 2020-05-10                   |
| NUM_CURRENT  | 表示数（本次） | 308.1                        |
| NUM_PREVIOUS | 表示数（上次） | 283.1                        |
| NUM_USAGE    | 用量（立方）   | 25                           |
| TOTAL_MONEY  | 合计金额       | 150                          |
| RECORD_DATE  | 查表日期       | 2020-04-25                   |
| LATEST_DATE  | 最迟缴费日期   | 2020-06-09                   |



~~~java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.IOException;

public class put_data {

    private Configuration configuration;
    private Connection connection;
    private Admin admin;

    @BeforeTest
    public void beforeTest() throws IOException {
        //1. 获取hbase的连接对象:
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
        //2. 获取执行操作的相关管理对象:  admin对象(对表的操作)  和  table对象 (对表数据的操作)
        admin = connection.getAdmin();
    }
    // 执行相关操作 插入姓名列数据
    @Test
    public void putTest() throws IOException {
        // 获取Hbase连接获取Htable
        TableName writeBilltableName = TableName.valueOf("WATER_BILL");
        Table writerBillTable = connection.getTable(writeBilltableName);

        // 构建ROWKEY ,列簇名,列名
        // 2.构建ROWKEY、列蔟名、列名
        String rowkey = "4944191";
        String cfName = "C1";
        String colName = "NAME";
        String colADDRESS = "ADDRESS";
        String colSEX = "SEX";
        String colPAY_DATE = "PAY_DATE";
        String colNUM_CURRENT = "NUM_CURRENT";
        String colNUM_PREVIOUS = "NUM_PREVIOUS";
        String colNUM_USAGE = "NUM_USAGE";
        String colTOTAL_MONEY = "TOTAL_MONEY";
        String colRECORD_DATE = "RECORD_DATE";
        String colLATEST_DATE = "LATEST_DATE";

         // 构建put对象 (对应put命令)
        Put put = new Put(Bytes.toBytes(rowkey));
        // 添加姓名
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colName)
                , Bytes.toBytes("登卫红"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colADDRESS)
                , Bytes.toBytes("贵州省铜仁市德江县7单元267室"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colSEX)
                , Bytes.toBytes("男"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colPAY_DATE)
                , Bytes.toBytes("2020-05-10"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colNUM_CURRENT)
                , Bytes.toBytes("308.1"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colNUM_PREVIOUS)
                , Bytes.toBytes("283.1"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colNUM_USAGE)
                , Bytes.toBytes("25"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colTOTAL_MONEY)
                , Bytes.toBytes("150"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colRECORD_DATE)
                , Bytes.toBytes("2020-04-25"));
        put.addColumn(Bytes.toBytes(cfName)
                , Bytes.toBytes(colLATEST_DATE)
                , Bytes.toBytes("2020-06-09"));
        // 对Htable表对象执行put操作
        writerBillTable.put(put);
        // 关闭表
        writerBillTable.close();

    }
    //4. 释放资源
    @AfterTest
    public void afterTest() throws IOException {
        admin.close();
        connection.close();
    }
}



~~~



# 查看一条表数据

~~~java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.IOException;
import java.util.List;

public class getOneTest {

    private Configuration configuration;
    private Connection connection;
    private Admin admin;

    @BeforeTest
    public void beforeTest() throws IOException {
        //1. 获取hbase的连接对象:
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
        //2. 获取执行操作的相关管理对象:  admin对象(对表的操作)  和  table对象 (对表数据的操作)
        admin = connection.getAdmin();
    }
    // 执行相关操作 插入姓名列数据
    @Test
    public void  getTest() throws IOException {
        // 1. 获取HTable
        TableName writeBillTableName = TableName.valueOf("WATER_BILL");
        Table writeBillTable = connection.getTable(writeBillTableName);
        // 使用rowkey 构建Get 对象
        Get get = new Get(Bytes.toBytes("4944191"));
        // 执行get请求
        Result result = writeBillTable.get(get);
        // 获取所有单元格
        List<Cell> cellList = result.listCells();
        // 打印rowkey
        System.out.println("rowkey => " + Bytes.toString(result.getRow()));

        // 5. 迭代单元格列表
        for (Cell cell : cellList) {
            // 打印列蔟名
            System.out.print(Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength()));
            System.out.println(" => " + Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));

        }

        // 6. 关闭表
        writeBillTable.close();

    }

    //4. 释放资源
    @AfterTest
    public void afterTest() throws IOException {
        admin.close();
        connection.close();
    }
}

~~~

# 删除数据

```java
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.Cell;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.*;
import org.apache.hadoop.hbase.util.Bytes;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Test;

import java.io.IOException;
import java.util.List;

public class deleteOneTest {

    private Configuration configuration;
    private Connection connection;
    private Admin admin;

    @BeforeTest
    public void beforeTest() throws IOException {
        //1. 获取hbase的连接对象:
        configuration = HBaseConfiguration.create();
        connection = ConnectionFactory.createConnection(configuration);
        //2. 获取执行操作的相关管理对象:  admin对象(对表的操作)  和  table对象 (对表数据的操作)
        admin = connection.getAdmin();
    }
    // 执行相关操作 插入姓名列数据
    @Test
    public void  deleteTest() throws IOException {
        // 1. 获取HTable对象
        Table waterBillTable = connection.getTable(TableName.valueOf("WATER_BILL"));

        // 2. 根据rowkey构建delete对象
        Delete delete = new Delete(Bytes.toBytes("4944191"));

        // 3. 执行delete请求
        waterBillTable.delete(delete);

        // 4. 关闭表
        waterBillTable.close();

    }

    //4. 释放资源
    @AfterTest
    public void afterTest() throws IOException {
        admin.close();
        connection.close();
    }
}
```

# 进行数据的导入导出

# 查询2020年6月份所有用户的用水量

```java
// 查询2020年6月份所有用户的用水量数据
@Test
public void queryTest1() throws IOException {
    // 1. 获取表
    Table waterBillTable = connection.getTable(TableName.valueOf("WATER_BILL"));
    // 2. 构建scan请求对象
    Scan scan = new Scan();
    // 3. 构建两个过滤器
    // 3.1 构建日期范围过滤器（注意此处请使用RECORD_DATE——抄表日期比较
    SingleColumnValueFilter startDateFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
            , Bytes.toBytes("RECORD_DATE")
            , CompareOperator.GREATER_OR_EQUAL
            , Bytes.toBytes("2020-06-01"));

    SingleColumnValueFilter endDateFilter = new SingleColumnValueFilter(Bytes.toBytes("C1")
            , Bytes.toBytes("RECORD_DATE")
            , CompareOperator.LESS_OR_EQUAL
            , Bytes.toBytes("2020-06-30"));

    // 3.2 构建过滤器列表
    FilterList filterList = new FilterList(FilterList.Operator.MUST_PASS_ALL
            , startDateFilter
            , endDateFilter);

    scan.setFilter(filterList);

    // 4. 执行scan扫描请求
    ResultScanner resultScan = waterBillTable.getScanner(scan);

    // 5. 迭代打印result
    for (Result result : resultScan) {
        System.out.println("rowkey -> " + Bytes.toString(result.getRow()));
        System.out.println("------");

        List<Cell> cellList = result.listCells();

        // 6. 迭代单元格列表
        for (Cell cell : cellList) {
            // 打印列蔟名
            System.out.print(Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength()));
            System.out.println(" => " + Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));

        }
        System.out.println("------");
    }

resultScanner.close();


    // 7. 关闭表
    waterBillTable.close();
}
```



或者

```sh
 @Test
    public void test07() throws Exception{

        //1. 根据连接工厂, 创建连接对象: @Before

        //2. 根据连接对象, 创建相关的管理对象:  @Before


        //3. 执行相关的操作:查询2020年6月份所有用户的用水量
        Scan scan = new Scan();  // 扫描全部数据

        SingleColumnValueFilter filter = new SingleColumnValueFilter(
                "C1".getBytes(), "RECORD_DATE".getBytes(), CompareOperator.EQUAL, new BinaryPrefixComparator("2020-08".getBytes()));
        scan.setFilter(filter);


        // 结果需要有: NAME NUM_USAGE
        scan.addColumn("C1".getBytes(),"NAME".getBytes());
        scan.addColumn("C1".getBytes(),"RECORD_DATE".getBytes());
        scan.addColumn("C1".getBytes(),"NUM_USAGE".getBytes());

        ResultScanner results = table.getScanner(scan);

        //4. 获取数据:
        for (Result result : results) {

            List<Cell> cellList = result.listCells();

            for (Cell cell : cellList) {

                String rowkey = Bytes.toString(CellUtil.cloneRow(cell));
                String family = Bytes.toString(CellUtil.cloneFamily(cell));
                String qualifier = Bytes.toString(CellUtil.cloneQualifier(cell));

                if(qualifier.equals("NUM_USAGE")){
                   Double value = Bytes.toDouble(CellUtil.cloneValue(cell));
                    System.out.println("rowkey为:"+rowkey +";列族为:"+family+";列名为:"+qualifier+";列值为:"+value);
                }else{
                    String value = Bytes.toString(CellUtil.cloneValue(cell));
                    System.out.println("rowkey为:"+rowkey +";列族为:"+family+";列名为:"+qualifier+";列值为:"+value);
                }



            }

            System.out.println("---------------------------");
        }


        //5. 释放资源

    }
```



# 解决乱码问题

```java
# 因为前面我们的代码，在打印所有的列时，都是使用字符串打印的，Hbase中如果存储的是int、double，那么有可能就会乱码了。


System.out.print(Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength()));
System.out.println(" => " + Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));

```

```java
要解决的话，我们可以根据列来判断，使用哪种方式转换字节码。如下：
1.NUM_CURRENT
2.NUM_PREVIOUS
3.NUM_USAGE
4.TOTAL_MONEY
这4列使用double类型展示，其他的使用string类型展示。
String colName = Bytes.toString(cell.getQualifierArray(), cell.getQualifierOffset(), cell.getQualifierLength());
System.out.print(colName);

if(colName.equals("NUM_CURRENT")
        || colName.equals("NUM_PREVIOUS")
        || colName.equals("NUM_USAGE")
        || colName.equals("TOTAL_MONEY")) {
    System.out.println(" => " + Bytes.toDouble(cell.getValueArray(), cell.getValueOffset()));
}
else {
    System.out.println(" => " + Bytes.toString(cell.getValueArray(), cell.getValueOffset(), cell.getValueLength()));
}
```

