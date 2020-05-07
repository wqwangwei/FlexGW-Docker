#!/bin/bash


#flexgw_refs="v1.0.0"
flexgw_refs="origin/master"
package_name="flexgw"
flexgw_version="1.1.0"
flexgw_release="1"
python_version="2.7.9"
python_dir="/usr/local/flexgw/python"

curdir=$(pwd)

if [ ! -f ./mkrpm.sh ]; then
    echo "please run this script in directory where mkrpm.sh located in"
    exit 1
fi

# 开启内核转发功能
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# 编译依赖包

yum install rpm-build python-pip zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel \
openssl-devel xz xz-devel libffi-devel gcc gcc-c++  git  -y

if ! `pip list | grep -q python-build`
then
	pip install python-build  -i http://pypi.douban.com/simple --trusted-host pypi.douban.com
fi

# https://github.com/meolu/walle-web/blob/master/admin.sh

#create necessary directories
mkdir -p /tmp/rpmbuild/SOURCES
mkdir -p /tmp/rpmbuild/PYTHON/cache
mkdir -p /tmp/rpmbuild/PYTHON/sources

[ -d /tmp/rpmbuild/SOURCES/flexgw ] && rm -rf /tmp/rpmbuild/SOURCES/flexgw

#clone repositories
git clone https://github.com/tomlinux/FlexGW /tmp/rpmbuild/SOURCES/flexgw

#archive source from git repositories
cd /tmp/rpmbuild/SOURCES/flexgw
git archive --format="tar" --prefix="$package_name-$flexgw_version/" $flexgw_refs|bzip2 > /tmp/rpmbuild/SOURCES/$package_name-$flexgw_version.tar.bz2

# rpmbuild
cd $curdir
rpmbuild --define "_topdir /tmp/rpmbuild" \
--define "package_name $package_name" \
--define "version $flexgw_version" \
--define "release $flexgw_release" \
--define "python_version $python_version" \
--define "python_dir $python_dir" \
-bb $curdir/flexgw.spec

rm -rf /tmp/rpmbuild/SOURCES
rm -rf /tmp/rpmbuild/BUILD
