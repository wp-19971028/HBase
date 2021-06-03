# 显示服务器状态

```sh
hbase(main):004:0> status
1 active master, 0 backup masters, 2 servers, 1 dead, 1.5000 average load
Took 4.3411 seconds   
```

# 显示HBASE当前用户

```sh
hbase(main):005:0> whoami
root (auth:SIMPLE)
    groups: root
Took 0.0298 seconds
```

# 查看所有的表

```sh
hbase(main):006:0> list
TABLE                                                                                           
ORDER_INFO                                                                                    
1 row(s)
Took 0.0524 seconds                                                                                 
=> ["ORDER_INFO"]
```

# 统计指定表记录数

```sh
hbase(main):007:0>  count 'ORDER_INFO'
66 row(s)
Took 0.0780 seconds                                                                                 
=> 66
```

# 展示表结构

```sh
hbase(main):008:0> describe 'ORDER_INFO'
Table ORDER_INFO is ENABLED                                                                         
ORDER_INFO                                                                                          
COLUMN FAMILIES DESCRIPTION                                                                         
{NAME => 'C1', VERSIONS => '1', EVICT_BLOCKS_ON_CLOSE => 'false', NEW_VERSION_BEHAVIOR => 'false', K
EEP_DELETED_CELLS => 'FALSE', CACHE_DATA_ON_WRITE => 'false', DATA_BLOCK_ENCODING => 'NONE', TTL => 
'FOREVER', MIN_VERSIONS => '0', REPLICATION_SCOPE => '0', BLOOMFILTER => 'ROW', CACHE_INDEX_ON_WRITE
 => 'false', IN_MEMORY => 'false', CACHE_BLOOMS_ON_WRITE => 'false', PREFETCH_BLOCKS_ON_OPEN => 'fal
se', COMPRESSION => 'NONE', BLOCKCACHE => 'true', BLOCKSIZE => '65536'}                             
1 row(s)
Took 0.1090 seconds                         
```

# 判断表是否存在

```sh
hbase(main):001:0> exists 'ORDER_INFO'
Table ORDER_INFO does exist                                                           
Took 0.4221 seconds                                                                   
=> true
```

# 检查表是否启用或禁用

```sh
2.4.1 :077 > is_enabled 'ORDER_INFO'
true                                                                                                                                                   
Took 0.0058 seconds                                                                                                                                    
 => true 
2.4.1 :078 > is_disabled 'ORDER_INFO'
false                                                                                                                                                  
Took 0.0085 seconds                                                                                                                                    
 => 1
```

# 改变表和列族的模式

```sh
# 创建一个USER_INFO表，两个列蔟C1、C2
create 'USER_INFO', 'C1', 'C2'
# 新增列蔟C3
alter 'USER_INFO', 'C3'
# 删除列蔟C3
alter 'USER_INFO', 'delete' => 'C3'
```

# 禁用表或者启用表

```sh
hbase(main):002:0> disable 'ORDER_INFO'
Took 0.5324 seconds                                                                   
hbase(main):003:0> enable 'ORDER_INFO'
Took 0.7745 seconds 
```

