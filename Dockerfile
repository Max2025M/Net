FROM ubuntu:22.04

# Instalar dependências
RUN apt-get update && \
    apt-get install -y wget iproute2 iptables golang-go && \
    apt-get clean

# Instalar wireguard-tools (wg, wg-quick)
RUN apt-get update && \
    apt-get install -y wireguard-tools && \
    apt-get clean

# Baixar e compilar wireguard-go (modo userspace)
RUN go install golang.zx2c4.com/wireguard/wgctrl@latest && \
    go install golang.zx2c4.com/wireguard/wireguard-go@latest && \
    mv /root/go/bin/wireguard-go /usr/local/bin/

# Copiar configuração
COPY wg0.conf /etc/wireguard/wg0.conf

# Expor porta UDP do WireGuard
EXPOSE 51820/udp

# Rodar em modo userspace
CMD ["wireguard-go", "wg0"]
