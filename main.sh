#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ ! -e /dev/net/tun ]; then
	echo 'FATAL: cannot start ZeroTier One in container: /dev/net/tun not present.'
	exit 1
fi

get_ip() {
	ip=$(curl -s https://ipinfo.io/ip) || ip=$(curl -s https://api.ip.sb/ip) || echo -e "\n$red 这垃圾小鸡扔了吧！$none\n"
}
zerotier-one &
sleep 5
get_ip
sleep 2
zerotier-cli join $ID
sleep 3
create_moon () {
    # 进入对应目录
    cd /var/lib/zerotier-one
    # 生成moon模板
    zerotier-idtool generate identity.public
    sleep 3
    zerotier-idtool initmoon identity.public >>moon.json
    # 获取本机公网IP,修改moon.json
    
    sleep 3
    sed -i s'/\[\]/\["'${ip}'\/9993"\]/g' moon.json
    # 生成签名文件
    zerotier-idtool genmoon moon.json
    # 将 moon 节点加入网络
    mkdir /var/lib/zerotier-one/moons.d
    mv *.moon ./moons.d/
}

# 没有moon，创建一个
if [ ! -d "/var/lib/zerotier-one/moons.d" ]; then
  create_moon
fi

# 重启进程
kill -9 `pidof zerotier-one`
sleep 5
zerotier-one &
while true; do sleep 1; done;

