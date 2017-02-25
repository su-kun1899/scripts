#!/usr/bin/env bash
# dump_single_table.sh
#
# -----------------------------------------------------------------------------
# Purpose : テーブル単体でdumpします
# -----------------------------------------------------------------------------
#
# Description :
#   1. 接続先データベースの情報はオプションで渡します
#   2. dump_single_table.sh -? でオプションの詳細が表示されます
#
# Usage :
#   $ dump_single_table.sh -t ${target_table_name} -n ${dump_file_name} -h ${host_name} -P ${port_num} -D ${db_name} -u ${user_name}
#
#   Example) $ dump_single_table.sh -t sample_table -n sample.sql -h 127.0.0.1 -P 3306 -D test -u root
#
#
# -----------------------------------------------------------------------------
set -eu

readonly SCRIPT_DIR=$(cd $(dirname $0);pwd)
cd ${SCRIPT_DIR}

# Default
db_user='root'
db_host='127.0.0.1'
db_port='3306'
db_name='sample'
table_name=''
dump_file_name=''

while getopts h:P:D:u:t:n:? OPT
do
  case ${OPT} in
    "h" ) db_host=$OPTARG ;;
    "P" ) db_port=$OPTARG ;;
    "D" ) db_name=$OPTARG ;;
    "u" ) db_user=$OPTARG ;;
    "t" ) table_name=$OPTARG ;;
    "n" ) dump_file_name=$OPTARG ;;
    "?" )
      echo '-h ${host_name}: 指定されたホストの MySQL サーバーに接続します。'
      echo '-P ${port_num}: 接続に使用する TCP/IP ポート番号。'
      echo '-D ${db_name}: 使用するデータベース。'
      echo '-u ${user_name}: サーバーへの接続時に使用する MySQL ユーザー名。'
      echo '-t ${table_name}: 対象のtable名。'
      echo '-n ${dump_file_name}: dumpファイル名。'
      exit 0
      ;;
  esac
done

if [ ! -n "${table_name}" ]; then
  echo "Target table is not found."
  exit 1
fi

if [ ! -n "${dump_file_name}" ]; then
  dump_file_name=${table_name}.sql
fi

echo "Dump target is \"${table_name}\"."
echo "Connect to ${db_host}:${db_port}/${db_name} as ${db_user}"

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
    > ${dump_file_name}

echo "\"${dump_file_name}\" is created successful."

exit 0