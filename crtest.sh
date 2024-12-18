#!/bin/bash

# 获取当前用户名
USER=$(whoami)
USER_LOWER="${USER,,}"
USER_HOME="/home/${USER_LOWER}"
HYSTERIA_WORKDIR="${USER_HOME}/.hysteria"
HYSTERIA_CONFIG="${HYSTERIA_WORKDIR}/config.yaml"  # Hysteria 配置文件路径

# 定义 crontab 任务

CRON_HYSTERIA="nohup ${HYSTERIA_WORKDIR}/web server -c ${HYSTERIA_CONFIG} >/dev/null 2>&1 &"

# 定义函数来添加 crontab 任务，减少重复代码
add_cron_job() {
  local job=$1
  (crontab -l 2>/dev/null | grep -F "$job") || (crontab -l 2>/dev/null; echo "$job") | crontab -
}



# Hysteria 的重启任务
if [ -f "$HYSTERIA_CONFIG" ]; then
  echo "添加 Hysteria 的 crontab 重启任务"
  add_cron_job "@reboot pkill -kill -u $USER && ${CRON_HYSTERIA}"
  add_cron_job "*/12 * * * * pgrep -x \"web\" > /dev/null || ${CRON_HYSTERIA}"
fi


echo "crontab 任务添加完成"
