#!/bin/bash

sysctl net.ipv4.ip_forward=1
sysctl net.ipv6.conf.all.forwarding=1

systemctl start  warp-svc
systemctl status warp-svc

warp-cli --version

if [[ ! -f /var/lib/cloudflare-warp/reg.json ]]
then
	warp-cli --accept-tos register	
fi

warp-cli --accept-tos set-mode "${WARP_MODE:-warp+doh}"
warp-cli --accept-tos set-families-mode "${FAMILY_MODE:-full}"
warp-cli --accept-tos connect

while ! warp-cli --accept-tos status 2>&1 | grep Connected
do
	sleep 1
done

curl https://www.cloudflare.com/cdn-cgi/trace/

ifconfig

iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -o CloudflareWARP -j MASQUERADE

iptables -S
iptables -t nat -S

tail -f /var/log/journal/warp-svc.service.log
