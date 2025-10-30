#!/usr/bin/env bash
source ./env.sh

gen_copy_sql(){
    sql="select count(*) from ${t}" 
    echo "${sql}"
    echo "$sql" |bendsql
    sql="analyze table ${t}"|bendsql

}
for t in customer lineitem nation orders partsupp part region supplier; do
    echo ${t}
    start=$(date +%s)
    gen_copy_sql
    end=$(date +%s)
    use_sec=$(( end - start ))
done

