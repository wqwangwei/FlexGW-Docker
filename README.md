# Flex GateWay in Docker
============

## 介绍
-------

fork from https://github.com/tomlinux/FlexGW
-------

## Docker 镜像

```yaml
version: "3"
services:
  flexgw:
    image: hualv/flexgw:latest
    network_mode: host
    restart: always
    environment:
      - 'DEBUG=true'
      - 'DEFAULT_PASSWORD=password'
    devices:
    - /dev/net/tun
    cap_add:
    - NET_ADMIN
    volumes:
    - /root/docker-flexgw/data/:/usr/local/flexgw/instance/
    #sysctls:
    #- net.core.somaxconn=1024
    #- net.ipv4.tcp_syncookies=0
```
访问地址：https://ip:4443 login:admin password:password

## SNAT配置
需要设置VPC默认路由0.0.0.0指向到当前IP
