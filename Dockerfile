FROM debian:12-slim

# Instalar pacotes necessários
RUN apt-get update && apt-get install -y curl ca-certificates unzip && apt-get clean && rm -rf /var/lib/apt/lists/*

# Baixar e instalar Xray-core
RUN mkdir -p /usr/local/bin/xray
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /usr/local/bin/xray && \
    mv /usr/local/bin/xray/xray /usr/local/bin/xray-core && \
    rm -rf /tmp/xray.zip

# Criar diretório de configuração
RUN mkdir -p /etc/xray
COPY config.json /etc/xray/config.json

# Expor porta interna do Xray (só acessível pelo proxy)
EXPOSE 10081

# Iniciar Xray
CMD ["sh", "-c", "/usr/local/bin/xray-core -config /etc/xray/config.json"]
