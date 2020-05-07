#!/bin/bash

yum install -y epel-release
yum install strongswan openvpn

source /etc/os-release

if [[ $ID ~= centos7 ]] || [[ $ID ~= fedora ]] || [[ $ID ~= rhel ]]
then
	echo "centos 7 是被支持的，请继续安装..... "
else 
	echo "该系统不被支持。  "
	exit 1 
fi


echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p



wget -O  /root/flexgw-1.1.0-1.el7.x86_64.rpm.zip  https://github.com/tomlinux/FlexGW/releases/download/v1.2/flexgw-1.1.0-1.el7.x86_64.rpm.zip
cd  /root && unzip flexgw-1.1.0-1.el7.x86_64.rpm.zip && rpm -ivh flexgw-1.1.0-1.el7.x86_64.rpm

\cp -fv /usr/local/flexgw/rc/strongswan.conf /etc/strongswan/strongswan.conf

\cp -fv /usr/local/flexgw/rc/openvpn.conf /etc/openvpn/server/server.conf


sed -i 's/load = yes/#load = yes/g' /etc/strongswan/strongswan.d/charon/dhcp.conf

echo ''> /etc/strongswan/ipsec.secrets


ln -s /etc/init.d/initflexgw /etc/rc3.d/S98initflexgw

echo "正在初始化证书和数据库文件请等会几分钟..........................."
/etc/init.d/initflexgw 
