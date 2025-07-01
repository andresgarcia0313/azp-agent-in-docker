#!/bin/bash

# Cargar variables del .env
set -o allexport
source .env
set +o allexport

# Construcción de la imagen
docker build --tag "$IMAGE_NAME" --file "$DOCKERFILE" .

# Separar nombres de agentes por coma
IFS=',' read -ra AGENTS <<< "$AGENT_NAMES"

# Crear contenedores para cada agente
for AGENT_NAME in "${AGENTS[@]}"; do
  docker run -d \
    --name "$AGENT_NAME" \
    --restart unless-stopped \
    -e AZP_URL="$AZP_URL" \
    -e AZP_TOKEN="$AZP_TOKEN" \
    -e AZP_POOL="$AZP_POOL" \
    -e AZP_AGENT_NAME="$AGENT_NAME" \
    "$IMAGE_NAME"
done
