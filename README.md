[![Docker Pulls](https://img.shields.io/docker/pulls/lihaixin/zerotier)](https://hub.docker.com/r/lihaixin/zerotier)

## zerotier-docker

#### 描述

这个容器镜像是基于Linux Alpine 制作的，用于在docker平台快速创建zerotier服务，加入特定的网络里

#### 运行

下面是快速运行命令

    docker run --name zerotier-one \
      --device=/dev/net/tun \
      --net=host \
      --cap-add=NET_ADMIN \
      --cap-add=SYS_ADMIN \
      -v /var/lib/zerotier-one:/var/lib/zerotier-one \
      --restart=always \
      lihaixin/zerotier



运行zerotier节点需要网络权限创建网卡，网卡名称是使用 zt#开头的接口，由于使用host网络模式，效果和真实网络效性能差不多，通过-v把容器里的文件挂载到宿主机，这样可以很方便的修改配置文件，例如把节点创建成为 moon点



下面演示加入全球公共网络节点

    docker exec zerotier-one /zerotier-cli join 8056c2e21c000001


也可以创建一个空白文件，文件名为网络节点名称

    touch /var/lib/zerotier-one/networks.d/8056c2e21c000001.conf

#### 源码

https://github.com/lihaixin/zerotier-docker
