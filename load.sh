#!/usr/bin/env bash

# 加载环境配置
source ./env.sh

# 配置变量
TABLES=("customer" "lineitem" "nation" "orders" "partsupp" "part" "region" "supplier")

# 函数：生成并执行COPY SQL
gen_copy_sql() {
    local table="$1"
    local copy_sql="copy into ${table} from @mydata/${database}/${table}/ pattern='.*[.]parquet' file_format=(type=parquet)"
    
    echo "Executing: ${copy_sql}"
    if echo "${copy_sql}" | bendsql; then
        echo "COPY command executed successfully for ${table}"
        
        # 分析表
        if echo "analyze table ${table}" | bendsql; then
            echo "ANALYZE command executed successfully for ${table}"
            return 0
        else
            echo "Error: ANALYZE command failed for ${table}" >&2
            return 1
        fi
    else
        echo "Error: COPY command failed for ${table}" >&2
        return 1
    fi
}

# 主执行逻辑
main() {
    # 检查必要的环境变量
    if [[ -z "${database}" ]]; then
        echo "Error: 'database' variable is not set in env.sh" >&2
        exit 1
    fi
    
    # 检查bendsql是否可用
    if ! command -v bendsql &> /dev/null; then
        echo "Error: bendsql command not found" >&2
        exit 1
    fi
    
    echo "Starting data load for database: ${database}"
    
    for table in "${TABLES[@]}"; do
        echo "Processing table: ${table}"
        local start=$(date +%s)
        
        if gen_copy_sql "${table}"; then
            local end=$(date +%s)
            local use_sec=$((end - start))
            echo "Load ${table} completed in: ${use_sec} seconds"
        else
            echo "Error: Failed to load table ${table}" >&2
            # 可以选择继续处理其他表或退出
            # exit 1  # 取消注释此项将在遇到错误时停止脚本
        fi
        
        echo "----------------------------------------"
    done
    
    echo "Data load process completed for all tables"
}

# 执行主函数
main "$@"