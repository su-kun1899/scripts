#!/bin/bash
# dump_by_table.sh
#
# -----------------------------------------------------------------------------
# Purpose : テーブルごとのdmlにしてmysqldumpを実行します
# -----------------------------------------------------------------------------
#
# Description :
#   1. 接続先データベースの情報はオプションで渡します
#   2. dump_by_table.sh -? でオプションの詳細が表示されます
#   3. DMLは./dml配下に出力されます
#
# Usage :
#   $ dump_by_table.sh -h ${host_name} -P ${port_num} -D ${db_name} -u ${user_name}
#
#   Example) $ dump_by_table.sh -h 127.0.0.1 -P 3306 -D test -u root
#
#
# -----------------------------------------------------------------------------
readonly SCRIPT_DIR=$(cd $(dirname $0);pwd)
readonly DML_DIR="${SCRIPT_DIR}/dml"
readonly TABLE_NAME_FILE=${SCRIPT_DIR}/tables.txt

# Default
db_user='root'
db_host='127.0.0.1'
db_port='3306'
db_name='test'

set -eu

while getopts h:P:D:u:? OPT
do
  case ${OPT} in
    "h" ) db_host=$OPTARG ;;
    "P" ) db_port=$OPTARG ;;
    "D" ) db_name=$OPTARG ;;
    "u" ) db_user=$OPTARG ;;
    "?" )
      echo '-h ${host_name}: 指定されたホストの MySQL サーバーに接続します。'
      echo '-P ${port_num}: 接続に使用する TCP/IP ポート番号。'
      echo '-D ${db_name}: 使用するデータベース。'
      echo '-u ${user_name}: サーバーへの接続時に使用する MySQL ユーザー名。'
      exit 0
      ;;
  esac
done

echo "Connect to ${db_host}:${db_port}/${db_name} as ${db_user}"


# テーブル名の取得
echo 'Getting table names...'
mysql \
  -u ${db_user} \
  -h ${db_host} \
  -P ${db_port} \
  -e "select table_name from information_schema.TABLES where TABLE_SCHEMA = '${db_name}' and TABLE_TYPE = 'BASE TABLE'" \
  -D ${db_name} \
  > ${TABLE_NAME_FILE}

# テーブル名を配列に格納
echo 'Putting table name array...'
i=0
target_tables=()
while read table_name
do
  # 先頭行は列名なので不要
  if [[ "$table_name" = 'table_name' ]]; then
    echo "[INFO] skip first line"
    continue
  fi

  # flyway用のテーブルは除外
  if [[ "$table_name" =~ schema_version* ]]; then
    echo "[INFO] skip ${table_name}"
    continue
  fi

  target_tables[$i]=${table_name}
  i=`expr ${i} + 1`
done < ${TABLE_NAME_FILE}
rm ${TABLE_NAME_FILE}

echo "[INFO] table count: ${#target_tables[@]}"

# dmp置き場のお掃除
echo 'Cleaning dump directory...'
rm -f ${DML_DIR}/*

#テーブルごとにdmp
echo 'Starting dump...'
i=0
for table_name in ${#target_tables[@]}
do
  i=`expr ${i} + 1`
  # echo "Dumping to V10301_${i}_0__${tablename}_dml.sql..."
  mysqldump \
    --user ${db_user} \
    -h ${db_host} \
    -P ${db_port} \
    --complete-insert \
    --hex-blob \
    --no-create-info \
    --single-transaction \
    ${db_name} \
    ${table_name} \
    > ${DML_DIR}/V10301_${i}_0__${table_name}_dml.sql
done

echo 'End'

exit 0