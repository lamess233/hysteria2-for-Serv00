# socks5-hysteria2-for-serv00
- 给 serv00 机器一键安装 hysteria2
forked from [gshtwy/socks5-hysteria2-for-Serv00-CT8](https://github.com/gshtwy/socks5-hysteria2-for-Serv00-CT8)
## 一键脚本
- 推荐Socks5 hysteria2 nohup模式
```bash
bash <(curl -s https://raw.githubusercontent.com/lamess233/hysteria2-for-Serv00/main/install-socks5-hysteria.sh)
```

## 清理服务器

```bash
pkill -kill -u 用户名
chmod -R 755 ~/* 
chmod -R 755 ~/.* 
rm -rf ~/.* 
rm -rf ~/*
```

## Github Actions保活
添加 Secrets.`ACCOUNTS_JSON` 变量
```json
[
  {"username": "cmliusss", "password": "7HEt(xeRxttdvgB^nCU6", "panel": "panel4.serv00.com", "ssh": "s4.serv00.com"},
  {"username": "cmliussss2018", "password": "4))@cRP%HtN8AryHlh^#", "panel": "panel7.serv00.com", "ssh": "s7.serv00.com"},
  {"username": "4r885wvl", "password": "%Mg^dDMo6yIY$dZmxWNy", "panel": "panel.ct8.pl", "ssh": "s1.ct8.pl"}
]
```
# cloudflare worker部署保活
## cloudflare 部署步骤
- 复制worker.js代码到cloudflare Workers保存
- Workers设置变量名称，添加 ACCOUNTS_JSON TELEGRAM_JSON 值，替换自己的账号 密码 面板
- 在设置里设置Cron 触发器，设置触发时间。

## worker部署变量
添加变量名称 ACCOUNTS_JSON 
添加变量值，复制下面代码替换成自己的账号 密码 面板

```json
[  
  { "username": "serv00user1", "password": "serv00password1", "panelnum": "0", "type": "serv00" },
  { "username": "serv00user2", "password": "serv00password2", "panelnum": "4", "type": "serv00" },
  { "username": "serv00user3", "password": "serv00password3", "panelnum": "7", "type": "serv00" },
  { "username": "ct8user1", "password": "ct8password1", "type": "ct8" },
  { "username": "ct8user2", "password": "ct8password2", "type": "ct8" }
]
```

添加变量名称 TELEGRAM_JSON 
添加变量值，复制下面代码替换成自己的TG TOKEN ID

```json
{
  "telegramBotToken": "YOUR_BOT_TOKEN",
  "telegramBotUserId": "YOUR_USER_ID"
}
```




# 致谢
[RealNeoMan](https://github.com/Neomanbeta/ct8socks)、[k0baya](https://github.com/k0baya)、[eooce](https://github.com/eooce)、[cmliu](https://github.com/cmliu)
