
# LABEL name="CentOS Base Image" \
#     vendor="CentOS" \
#     license="GPLv2" \
#     build-date="20170911"

# CMD ["/bin/bash"]

FROM  centos:centos7.4.1708
MAINTAINER from tomlinux<xuliang12187@gmail.com>
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone \
	&& yum install -y epel-release \
	&& yum install -y wget curl unzip zip openssl openssl-devel dmidecode  strongswan openvpn \
	&& wget -O  /root/flexgw-1.1.0-1.el7.x86_64.rpm.zip  https://github.com/tomlinux/FlexGW/releases/download/v1.2/flexgw-1.1.0-1.el7.x86_64.rpm.zip \
	&& cd /root && unzip flexgw-1.1.0-1.el7.x86_64.rpm.zip \
	&& rpm -ivh flexgw-1.1.0-1.el7.x86_64.rpm \
	&& rm -f flexgw-1.1.0-1.el7.x86_64.rpm \
	&& \cp -fv /usr/local/flexgw/rc/strongswan.conf /etc/strongswan/strongswan.conf \
	&& \cp -fv /usr/local/flexgw/rc/openvpn.conf /etc/openvpn/server/server.conf \
	&& sed -i 's/load = yes/#load = yes/g' /etc/strongswan/strongswan.d/charon/dhcp.conf \
	&& echo ''> /etc/strongswan/ipsec.secrets \
	&& ln -s /etc/init.d/initflexgw /etc/rc3.d/S98initflexgw \
	&& /etc/init.d/initflexgw

EXPOSE 443
# ipsec 端口号
EXPOSE 500
EXPOSE 4500
#openvpn端口号
EXPOSE 1194

CMD ["/usr/local/flexgw/python/bin/gunicorn", "-c", "/usr/local/flexgw/gunicorn.py","website:app", "--pythonpath", "/usr/local/flexgw"]


