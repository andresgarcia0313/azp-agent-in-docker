# Base: Ubuntu 22.04
FROM ubuntu:22.04

# Arquitectura del agente (linux-x64, linux-arm, linux-arm64)
ENV TARGETARCH="linux-x64"

# Actualización e instalación de dependencias básicas
RUN apt update && \
    apt upgrade -y && \
    apt install -y curl git jq libicu70

# Instalación de Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Definir directorio de trabajo
WORKDIR /azp/

# Copiar y dar permisos al script de arranque
COPY ./start.sh ./
RUN chmod +x ./start.sh

# Crear usuario no privilegiado para ejecutar el agente
RUN useradd -m -d /home/agent agent && \
    chown -R agent:agent /azp /home/agent

# Cambiar a usuario 'agent'
USER agent

# Punto de entrada: arrancar el script
ENTRYPOINT [ "./start.sh" ]
