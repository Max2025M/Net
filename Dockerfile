FROM teddysun/xray:latest

# Copia a configuração
COPY config.json /etc/xray/config.json

# Expõe a porta TCP/UDP
EXPOSE 443/tcp
EXPOSE 443/udp

# Start do Xray em modo debug (stdout)
CMD ["xray", "-config", "/etc/xray/config.json", "-format", "console", "-loglevel", "debug"]
