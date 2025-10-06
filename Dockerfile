# Base Ubuntu
FROM ubuntu:22.04

# Instala WireGuard
RUN apt-get update && \
    apt-get install -y wireguard iproute2 iptables curl && \
    apt-get clean

# Copia o arquivo de configuração do servidor
COPY wg0.conf /etc/wireguard/wg0.conf

# Expor a porta UDP do WireGuard
EXPOSE 51820/udp

# Iniciar WireGuard automaticamente
CMD ["wg-quick", "up", "wg0"]
