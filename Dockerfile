FROM teddysun/xray:latest

# Copia a configuração
COPY config.json /etc/xray/config.json

# Expõe a porta TCP/UDP
EXPOSE 443/tcp
EXPOSE 443/udp

# Start do Xray normalmente (logs configurados no config.json)
CMD ["xray", "-config", "/etc/xray/config.json"]
