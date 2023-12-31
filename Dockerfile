FROM ubuntu:jammy
MAINTAINER Isaac

# Ref: https://pkg.cloudflareclient.com

# Volume
VOLUME /var/lib/cloudflare-warp
#EXPOSE 8080/tcp

# Install curl
RUN apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y gpg curl libcap2-bin systemctl iptables ipset net-tools netcat lsof vim-tiny 

# Add cloudflare gpg key
RUN curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg 

# Add apt repositories
RUN echo "deb [arch=amd64 signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ jammy main" | tee /etc/apt/sources.list.d/cloudflare-client.list

# Install cloudflare-warp
RUN apt-get update \
&& DEBIAN_FRONTEND=noninteractive apt-get install -y cloudflare-warp \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cache ~/.npm /var/log/* \
&& echo "net.ipv4.ip_forward=1" >>/etc/sysctl.d/20-ip-forward.conf \
&& echo "net.ipv6.conf.all.forwarding=1" >>/etc/sysctl.d/20-ip-forward.conf \
&& mkdir -p /root/.local/share \
&& mkdir -p /var/lib/cloudflare-warp \
&& ln -s /var/lib/cloudflare-warp /root/.local/share/warp \
&& touch /root/.local/share/warp/accepted-tos.txt

ADD run.sh /opt/

RUN chmod 755 /opt/*.sh

ENTRYPOINT [ "/opt/run.sh" ]
