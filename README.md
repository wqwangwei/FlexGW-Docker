# Flex GateWay in Docker
============

## 介绍
Flex GateWay in Docker

fork from https://github.com/tomlinux/FlexGW

本程序提供了VPN、SNAT 基础服务。

主要提供以下几点功能：
1.  IPSec Site-to-Site 功能。可快速的帮助你将两个不同的VPC 私网以IPSec Site-to-Site 的方式连接起来。
2.  拨号VPN 功能。可让你通过拨号方式，接入VPC 私网，进行日常维护管理。
3.  SNAT 功能。可方便的设置Source NAT，以让VPC 私网内的VM 通过Gateway VM 访问外网。


## 安装 Docker

### 安装 docker
使用官方安装脚本自动安装：
```shell
curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
```

### 安装 docker-compose

Linux 上我们可以从 Github 上下载它的二进制包来使用，最新发行的版本地址：[https://github.com/docker/compose/releases](https://github.com/docker/compose/releases)。

运行以下命令以下载 Docker Compose 的当前稳定版本：
```shell
sudo curl -L "https://github.com/docker/compose/releases/download/v2.10.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

## 配置Docker-compose

创建 compose 配置文件 `mkdir -p /opt/flexgw && cd /opt/flexgw && touch docker-compose.yml`
```yaml
version: "3"
services:
  flexgw:
    image: hualv/flexgw:latest
    network_mode: host
    environment:
      - 'DEBUG=true'
      - 'DEFAULT_PASSWORD=password'
    devices:
    - /dev/net/tun
    cap_add:
    - NET_ADMIN
    volumes:
    - /data/flexgw:/usr/local/flexgw/instance/
```

创建 compose 启动脚本 `vi /etc/systemd/system/flexgw.service`
```shell
[Unit]
Description=Docker Compose Application Service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/flexgw/
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose stop
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

systemd 管理程序
```shell
# 设置开机启动
systemctl enable --now flexgw.service

# 启动
systemctl start flexgw.service

# 停止
systemctl stop flexgw.service
```

访问地址：https://ip:12345 login:admin password:password

## 配置防火墙转发

### 开启路由转发功能

```shell
sed -i '/net.ipv4.ip_forward/s/0/1/' /etc/sysctl.conf
sed -i '/net.ipv4.ip_forward/s/#//' /etc/sysctl.conf
sysctl -p
```

### 配置 iptables

```shell
放行端口
iptables -I INPUT -p tcp --dport 23451 -m comment --comment "openvpn" -j ACCEPT

说明规则
iptables -t nat -A POSTROUTING -s vpn分配网段/24 -o eth0 -j MASQUERADE

保存规则-保证重启生效
iptables-save > /etc/sysconfig/iptables
```

## SNAT配置
需要设置VPC默认路由0.0.0.0指向到当前IP

## 程序说明
ECS VPN（即本程序）

-   目录：/usr/local/flexgw
-   数据库文件：/usr/local/flexgw/instance/website.db
-   日志文件：/usr/local/flexgw/logs/website.log
-   启动脚本：/etc/init.d/flexgw 或/usr/local/flexgw/website_console
-   实用脚本：/usr/local/flexgw/scripts

「数据库文件」保存了我们所有的VPN 配置，建议定期备份。如果数据库损坏，可通过「实用脚本」目录下的initdb.py 脚本对数据库进行初始化，初始化之后所有的配置将清空。

Strongswan

-   目录：/etc/strongswan
-   日志文件：/var/log/strongswan.charon.log
-   启动脚本：/usr/sbin/strongswan

如果strongswan.conf 配置文件损坏，可使用备份文件/usr/local/flexgw/rc/strongswan.conf 进行覆盖恢复。

ipsec.conf 和ipsec.secrets 配置文件，由/usr/local/flexgw/website/vpn/sts/templates/sts 目录下的同名文件自动生成，请勿随便修改。

OpenVPN

-   目录：/etc/openvpn
-   日志文件：/etc/openvpn/openvpn.log
-   状态文件：/etc/openvpn/openvpn-status.log
-   原启动脚本：/etc/init.d/openvpn

server.conf 配置文件，由/usr/local/flexgw/website/vpn/dial/templates/dial 目录下的同名文件自动生成，请勿随便修改。

