#!/bin/bash

# 介绍信息
echo -e "\e[32m
  ____   ___   ____ _  ______ ____  
 / ___| / _ \ / ___| |/ / ___| ___|  
 \___ \| | | | |   | ' /\___ \___ \ 
  ___) | |_| | |___| . \ ___) |__) |           不要直连
 |____/ \___/ \____|_|\_\____/____/            没有售后   
 缝合怪：cmliu 原作者们：RealNeoMan、k0baya、eooce
\e[0m"

# 获取当前用户名
USER=$(whoami)
WORKDIR="/home/${USER,,}/.nezha-agent"
FILE_PATH="/home/${USER,,}/.s5"
mkdir -p "$WORKDIR"
mkdir -p "$FILE_PATH"

###################################################

# 随机生成密码函数
generate_password() {
  export PASSWORD=${PASSWORD:-$(openssl rand -base64 12)}
}

# 设置服务器端口函数
set_server_port() {
  read -p "请输入服务器端口（默认 20026）: " input_port
  export SERVER_PORT="${input_port:-20026}"
}

# 下载依赖文件函数
download_dependencies() {
  ARCH=$(uname -m)
  DOWNLOAD_DIR="$WORKDIR"
  mkdir -p "$DOWNLOAD_DIR"
  FILE_INFO=()

  if [[ "$ARCH" == "arm"* || "$ARCH" == "aarch64" ]]; then
    FILE_INFO=("https://download.hysteria.network/app/latest/hysteria-freebsd-arm64 web" "https://github.com/eooce/test/releases/download/ARM/swith npm")
  elif [[ "$ARCH" == "amd64" || "$ARCH" == "x86_64" || "$ARCH" == "x86" ]]; then
    FILE_INFO=("https://download.hysteria.network/app/latest/hysteria-freebsd-amd64 web" "https://github.com/eooce/test/releases/download/freebsd/swith npm")
  else
    echo "不支持的架构: $ARCH"
    exit 1
  fi

  for entry in "${FILE_INFO[@]}"; do
    URL=$(echo "$entry" | cut -d ' ' -f 1)
    NEW_FILENAME=$(echo "$entry" | cut -d ' ' -f 2)
    FILENAME="$DOWNLOAD_DIR/$NEW_FILENAME"
    if [ -e "$FILENAME" ]; then
      echo -e "\e[1;32m$FILENAME 已存在，跳过下载\e[0m"
    else
      curl -L -sS -o "$FILENAME" "$URL"
      if [ $? -ne 0 ]; then
        echo -e "\e[1;31m下载 $FILENAME 失败\e[0m"
        exit 1
      fi
      echo -e "\e[1;32m下载 $FILENAME\e[0m"
    fi
    chmod +x "$FILENAME"
  done
}

# 生成证书函数
generate_cert() {
  openssl req -x509 -nodes -newkey ec:<(openssl ecparam -name prime256v1) -keyout "$WORKDIR/server.key" -out "$WORKDIR/server.crt" -subj "/CN=bing.com" -days 36500
}

# 生成配置文件函数
generate_config() {
  cat << EOF > "$WORKDIR/config.yaml"
listen: :$SERVER_PORT

tls:
  cert: $WORKDIR/server.crt
  key: $WORKDIR/server.key

auth:
  type: password
  password: "$PASSWORD"

fastOpen: true

masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true

transport:
  udp:
    hopInterval: 30s
EOF
}

# 运行下载的文件函数
run_files() {
  if [ -e "$WORKDIR/web" ]; then
    nohup "$WORKDIR/web" server "$WORKDIR/config.yaml" >/dev/null 2>&1 &
    sleep 1
    if pgrep -f "$WORKDIR/web" > /dev/null; then
      echo -e "\e[1;32mweb 正在运行\e[0m"
    else
      echo -e "\e[1;31mweb 启动失败\e[0m"
      exit 1
    fi
  else
    echo -e "\e[1;31m$WORKDIR/web 不存在\e[0m"
    exit 1
  fi
}

# 获取IP地址函数
get_ip() {
  ipv4=$(curl -s ipv4.ip.sb)
  if [ -n "$ipv4" ]; then
    HOST_IP="$ipv4"
  else
    ipv6=$(curl -s --max-time 1 ipv6.ip.sb)
    if [ -n "$ipv6" ]; then
      HOST_IP="$ipv6"
    else
      echo -e "\e[1;35m无法获取IPv4或IPv6地址\033[0m"
      exit 1
    }
  fi
  echo -e "\e[1;32m本机IP: $HOST_IP\033[0m"
}

# 获取网络信息函数
get_ipinfo() {
  ISP=$(curl -s https://speed.cloudflare.com/meta | awk -F\" '{print $26"-"$18}' | sed -e 's/ /_/g')
}

# 输出配置函数
print_config() {
  echo -e "\e[1;32mHysteria2 安装成功\033[0m"
  echo ""
  echo -e "\e[1;33mV2rayN或Nekobox 配置\033[0m"
  echo -e "\e[1;32mhysteria2://$PASSWORD@$HOST_IP:$SERVER_PORT/?sni=www.bing.com&alpn=h3&insecure=1#$ISP\033[0m"
  echo ""
  echo -e "\e[1;33mSurge 配置\033[0m"
  echo -e "\e[1;32m$ISP = hysteria2, $HOST_IP, $SERVER_PORT, password = $PASSWORD, skip-cert-verify=true, sni=www.bing.com\033[0m"
  echo ""
  echo -e "\e[1;33mClash 配置\033[0m"
  cat << EOF
- name: $ISP
  type: hysteria2
  server: $HOST_IP
  port: $SERVER_PORT
  password: $PASSWORD
  alpn:
    - h3
  sni: www.bing.com
  skip-cert-verify: true
  fast-open: true
EOF
}

# 删除临时文件函数
cleanup() {
  rm -rf "$WORKDIR/web" "$WORKDIR/config.yaml"
}

# 安装和配置 socks5
socks5_config() {
  # 提示用户输入 socks5 端口号
  read -p "请输入 socks5 端口号: " SOCKS5_PORT

  # 提示用户输入用户名和密码
  read -p "请输入 socks5 用户名: " SOCKS5_USER

  while true; do
    read -p "请输入 socks5 密码（不能包含@和:）：" SOCKS5_PASS
    echo
    if [[ "$SOCKS5_PASS" == *"@"* || "$SOCKS5_PASS" == *":"* ]]; then
      echo "密码中不能包含@和:符号，请重新输入。"
    else
      break
    fi
  done

  # config.json 文件
  cat > ${FILE_PATH}/config.json << EOF
{
  "log": {
    "access": "/dev/null",
    "error": "/dev/null",
    "loglevel": "none"
  },
  "inbounds": [
    {
      "port": "$SOCKS5_PORT",
      "protocol": "socks",
      "tag": "socks",
      "settings": {
        "auth": "password",
        "udp": false,
        "ip": "0.0.0.0",
        "userLevel": 0,
        "accounts": [
          {
            "user": "$SOCKS5_USER",
            "pass": "$SOCKS5_PASS"
          }
        ]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom"
    }
  ]
}
EOF
}

install_socks5() {
  socks5_config
  if [ ! -e "${FILE_PATH}/s5" ]; then
    curl -L -sS -o "${FILE_PATH}/s5" "https://github.com/eooce/test/releases/download/freebsd/web"
  else
    read -p "socks5 程序已存在，是否重新下载覆盖？(Y/N 回车N)" downsocks5
    downsocks5=${downsocks5^^} # 转换为大写
    if [ "$downsocks5" == "Y" ];then
      curl -L -sS -o "${FILE_PATH}/s5" "https://github.com/eooce/test/releases/download/freebsd/web"
    else
      echo "使用已存在的 socks5 程序"
    fi
  fi

  if [ -e "${FILE_PATH}/s5" ]; then
    chmod 777 "${FILE_PATH}/s5"
    nohup ${FILE_PATH}/s5 -c ${FILE_PATH}/config.json >/dev/null 2>&1 &
    sleep 2
    pgrep -x "s5" > /dev/null && echo -e "\e[1;32ms5 正在运行\e[0m" || { echo -e "\e[1;35ms5 未运行，重试安装\e[0m"; exit 1; }
  else
    echo -e "\e[1;35ms5 程序不存在\e[0m"
    exit 1
  fi
}

# 主执行流程
generate_password
set_server_port
download_dependencies
generate_cert
generate_config
run_files
get_ip
get_ipinfo
print_config
cleanup
install_socks5