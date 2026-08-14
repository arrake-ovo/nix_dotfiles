#!/bin/zsh
# 开启代理：读取 /etc/resolv.conf 的 DNS，作为 Clash（7890）的宿主机 IP
# 用法：source proxy.sh（必须 source，export 才对当前 shell 生效）
export hostip=$(awk '/^nameserver[[:space:]]/ { print $2; exit }' /etc/resolv.conf)
export https_proxy="http://${hostip}:7890"
export http_proxy="http://${hostip}:7890"
echo $hostip
