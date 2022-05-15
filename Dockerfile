FROM  centos:7

WORKDIR /usr/local/flexgw

VOLUME [ "/usr/local/flexgw/instance" ]



RUN set -ex ; \
	cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo 'Asia/Shanghai' >/etc/timezone \
	&& curl -o /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo \
	&& yum makecache \
	&& yum install -y python-devel python-pip wget curl unzip zip openssl openssl-devel dmidecode  strongswan openvpn gcc \
	&& openssl dhparam -out /etc/openvpn/dh2048.pem 2048
	# && yum clean all \
	# install python packages first

COPY requirements.txt .
RUN pip install -r requirements.txt -i http://pypi.douban.com/simple --trusted-host pypi.douban.com

COPY --from=hualv/supervisord:latest /usr/local/bin/supervisord /usr/local/bin/
COPY rc/supervisord.conf /etc/supervisord.conf

# install flexgw
COPY . .
RUN set -ex \
	&& mv docker-entrypoint.sh / \
	&& cp -f rc/strongswan.conf /etc/strongswan/strongswan.conf \
	&& cp -f rc/openvpn.conf /etc/openvpn/server.conf \
	# backup application.cfg
	&& cp -f instance/application.cfg . \
	&& sed -i 's/load = yes/#load = yes/g' /etc/strongswan/strongswan.d/charon/dhcp.conf \
	&& echo -e '#!/usr/bin/env bash\nexec supervisord ctl $*'> /usr/local/bin/supervisorctl \
	&& echo ''> /etc/strongswan/ipsec.secrets \
	&& chmod +x /usr/local/flexgw/scripts/* \
		/docker-entrypoint.sh \
		/usr/local/bin/supervisorctl

EXPOSE 443 500 4500 1194 9001
# ipsec 端口号 500 4500
# openvpn端口号 1194
# supervisord端口号 9001
ENV DEBUG=false

ENTRYPOINT [ "/docker-entrypoint.sh" ]

CMD [ "supervisord"]