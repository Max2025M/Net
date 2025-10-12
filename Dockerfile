FROM debian:12

# Corrigir possíveis repositórios quebrados e instalar pacotes necessários
RUN sed -i 's|deb.debian.org|deb.debian.org|g' /etc/apt/sources.list \
    && apt-get clean \
    && apt-get update --fix-missing \
    && apt-get install -y --no-install-recommends curl unzip netcat-traditional ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Baixar e instalar Xray-core
RUN mkdir -p /usr/local/bin/xray
RUN curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/xray \
    && mv /usr/local/bin/xray/xray /usr/local/bin/xray-core \
    && chmod +x /usr/local/bin/xray-core \
    && rm -rf /tmp/xray.zip

# Criar diretório de configuração
RUN mkdir -p /etc/xray
COPY config.json /etc/xray/config.json

# Expor porta necessária para o Render detectar o serviço
EXPOSE 8080

# Iniciar Xray e manter a porta 8080 ativa para o Render detectar o serviço
CMD ["sh", "-c", "/usr/local/bin/xray-core -config /etc/xray/config.json & while true; do nc -lk -p 8080 -e echo 'Servidor ativo'; done"]
