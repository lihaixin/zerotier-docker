#!/bin/sh

export PATH=/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin

if [ ! -e /dev/net/tun ]; then
	echo 'FATAL: cannot start ZeroTier One in container: /dev/net/tun not present.'
	exit 1
fi

get_ip() {
	ip=$DOMAIN
	[[ -z $ip ]] && ip=$(curl -s https://ipinfo.io/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.ip.sb/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.ipify.org)
	[[ -z $ip ]] && ip=$(curl -s https://ip.seeip.org)
	[[ -z $ip ]] && ip=$(curl -s https://ifconfig.co/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && ip=$(curl -s icanhazip.com)
	[[ -z $ip ]] && ip=$(curl -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && echo -e "\n$red 这垃圾小鸡扔了吧！$none\n" && exit
}

zerotier-cli join $ID

create_moon () {
    # 进入对应目录
    cd /var/lib/zerotier-one
    # 生成moon模板
    zerotier-idtool initmoon identity.public >>moon.json
    # 获取本机公网IP,修改moon.json
    get_ip
    sed -i s'/\[\]/\["$ip/9993"\]/g' moon.json
    # 生成签名文件
    zerotier-idtool genmoon moon.json
    # 将 moon 节点加入网络
    mkdir /var/lib/zerotier-one/moons.d
    mv 000000*.moon ./moons.d/
}

# 没有moon，创建一个
if [ ! -d "/var/lib/zerotier-one/moons.d" ]; then
  create_moon
fi

zerotier-one -p0
