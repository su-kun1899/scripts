#!/usr/bin/env bash
# replace-file-name.sh
#
# -----------------------------------------------------------------------------
# Purpose : 特定ディレクトリにあるファイルの名前を一度に置換します
# -----------------------------------------------------------------------------
#
# Description :
#   1. TODO
#   2.
#   3.
#
# Usage :
#   TODO
#
#   Example) TODO
#
#
# -----------------------------------------------------------------------------
set -eu

readonly SCRIPT_DIR=$(cd $(dirname $0);pwd)
# TODO 対象ディレクトリは外から渡せるといいなぁ
readonly TARGET_DIR=.
cd ${TARGET_DIR}


for current_name in `ls`
do
  # TODO 正規表現を変更する
  new_name=`echo ${current_name} | sed -e "s/hoge/fuga/"`

  if [ ${current_name} = ${new_name} ]; then
    continue
  fi

  echo "Rename ${current_name} to ${new_name}"
  mv ${current_name} ${new_name}
done

exit 0