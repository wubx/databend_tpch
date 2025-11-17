#WH="medium-mms5"
#HOST="{租户ID}--${wh}.gw.aliyun-cn-beijing.default.databend.cn"
HOST="192.168.1.201"
USER="wubx"
PASSWORD="wubxwubx"
# 私有化环境 8000 , Databend Cloud 443
PORT=8000
DATABASE="tpch_100"

# 私有化环境
export BENDSQL_DSN="databend://${USER}:${PASSWORD}@${HOST}:${PORT}/${DATABASE}?sslmode=disable"

# Databend Cloud环境 需要注意在 Databend Cloud 需要指定warehouse
#export BENDSQL_DSN="databend://${USER}:${PASSWORD}@${HOST}:${PORT}/${DATABASE}?warehouse=${WH}"

options="enable_parquet_dictionary = 'true'"

#options="storage_format = 'native' compression = 'lz4'"
#storage="'s3://wubx/data/' CONNECTION=(CONNECTION_name='wubx_conn') "
#options=""
#conn="'s3://wubx/data/' CONNECTION=(CONNECTION_name='wubx_conn')"
