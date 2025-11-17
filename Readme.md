# Databend 的 TPCH 测试

## 适用范围
本文档适用于 Databend & Databend Cloud 的 TPCH 压测。

## 基本思路
1. 准备好 s3 相应的 bucket endpoint_url, ak/sk 等信息
2. 安装 duckdb 用于产生 TPCH 数据: https://duckdb.org/#quickinstall 下载对应的二进制也可以
3. 调整 tpch_gen_duckdb.sh 对应变量，其中 s3 部分是用于产生 TPCH 数据存储位置，运行该脚本生成数据
4. 创建 s3 连接信息定义，参考： myconn.sh 
5. 安装 bendsql 可以参考: install_bendsql.sh
6. 通过在 Databend Cloud 创建外部 stage 访问产生的 TPCH 原始数据
7. 修订 env.sh 定义连接的 Databend 环境
8. 创建表结构： create_tb.sh
9. 加载数据： locad.sh 
10. 运行基本的测试 ./run.sh

## 注意事项
上述脚本中需要根据实际项目的情况修改，一般为可以把对应存储为分：
1. 阿里云 OSS, 阿里云的OSS 用 S3 访问时启用了 enable_virtual_host_style=true
2. 其它云 S3 产品
3. 私有化没启用 ssl 通信的产品, 需要 tpch_gen_duckdb.sh 定义没使用 ssl 

## 以 Databend Cloud 阿里云举例
注册 Databend Cloud 阿里云北京区
### 1. 准备 oss 相关信息
在华北2区创建 bucket,基本信息如下：
bucket名字: bjwubx
endpoint地址： oss-cn-beijing-internal.aliyuncs.com   这里南要注意阿里云的 oss 是加上 https 使用
ak:  myak
sk:  mysk

### 2. 安装 duckdb 
按官方手册进行即可，或是下载对应的二进制文件放到服务器上即可。

### 3. 修订 tpch_gen_duckdb.sh
主要修改如下：
```
# 配置变量
SF=100
MAX_INDEX=$((SF - 1))

D="tpch_${SF}"
S3_ENDPOINT="oss-cn-beijing-internal.aliyuncs.com"
S3_ACCESS_KEY="myak"
S3_SECRET_KEY="mysk"
S3_BUCKET="bjwubx"

S3_USE_SSL="true"  # 可以是 true 或 false
S3_URL_STYLE="vhost"  # 可以是 'path' 或 'vhost'
```
然后运行即可。

数据会写在： s3://bjwubx/mystage/tpch_100/ 类似这样的前缀下面。

### 4. 创建 s3 连接信息定义

```
create or replace connection myconn  storage_type='s3' endpoint_url='https://oss-cn-beijing-internal.aliyuncs.com' access_key_id='myak' secret_access_key='mysk' region=='cn-beijing' enable_virtual_host_style=true;
```
> 或是用 stroage_type='oss' ，例如：
```
create or replace connection myconn  storage_type='oss' endpoint_url='https://oss-cn-beijing-internal.aliyuncs.com' access_key_id='myak' access_key_secret='mysk' region=='cn-beijing';
```
两者测试上无任何性能区别。

### 5. 安装 bendsql 
参考： install_bendsql.sh

### 6. 创建外部 Stage 
在 Databend 中执行
```
create or replace stage mystage 's3://bjwubx/mystage/' connection=(connection_name='myconn');
```

使用下面命令校验：
```
list @mystage;
```
可以看到应的文件即成功。

### 7. 修改 env.sh
建议把压测中公共使用的变化放到 env.sh 中定义

```
# Databend Cloud
#测试用的 Warehouse 名称， 这块信息也可以参考云平台中的连接信息
#WH="medium-mms5"
#HOST="{租户ID}--${wh}.gw.aliyun-cn-beijing.default.databend.cn"
#PORT=443

# 私有化
HOST="192.168.1.201"
# 私有化环境 8000 , Databend Cloud 443
PORT=8000

USER="wubx"
PASSWORD="wubxwubx"
DATABASE="tpch_100"

# Databend Cloud环境 需要注意在 Databend Cloud 需要指定warehouse
#export BENDSQL_DSN="databend://${USER}:${PASSWORD}@${HOST}:${PORT}/${DATABASE}?warehouse=${WH}"

# 私有化环境
export BENDSQL_DSN="databend://${USER}:${PASSWORD}@${HOST}:${PORT}/${DATABASE}?sslmode=disable"

options="enable_parquet_dictionary = 'true'"

#options="storage_format = 'native' compression = 'lz4'"
#storage="'s3://bjwubx/data/' CONNECTION=(CONNECTION_name='wubx_conn') "
#options=""
#conn="'s3://bjwubx/data/' CONNECTION=(CONNECTION_name='wubx_conn')"
```

其中 storage 可以指定把表创建放到用户端指定的 bucket 中，这样可以实现，只用 Databend Cloud 托管的计算。

### 8. 创建表结构
```
./create_tb.sh
```

### 9. 加载数据


```
./load.sh
```

### 10. 执行压测

```
time ./run.sh
```