#!/bin/bash
set -e

# Validar variables obligatorias
if [ -z "${AZP_URL}" ]; then
  echo "error: falta AZP_URL" >&2
  exit 1
fi

# Si se usan credenciales de entidad de servicio
if [ -n "${AZP_CLIENTID}" ]; then
  echo "Usando credenciales de entidad de servicio"
  az login --allow-no-subscriptions \
           --service-principal \
           --username "${AZP_CLIENTID}" \
           --password "${AZP_CLIENTSECRET}" \
           --tenant "${AZP_TENANTID}"
  AZP_TOKEN=$(az account get-access-token --query accessToken --output tsv)
fi

# Preparar token si no existe AZP_TOKEN_FILE
if [ -z "${AZP_TOKEN_FILE}" ]; then
  if [ -z "${AZP_TOKEN}" ]; then
    echo "error: falta AZP_TOKEN" >&2
    exit 1
  fi
  AZP_TOKEN_FILE="/azp/.token"
  echo -n "${AZP_TOKEN}" > "${AZP_TOKEN_FILE}"
fi

# Limpiar variables sensibles
unset AZP_CLIENTSECRET AZP_TOKEN

# Crear directorio de trabajo si se especifica
if [ -n "${AZP_WORK}" ]; then
  mkdir -p "${AZP_WORK}"
fi

# Función de limpieza al salir
cleanup() {
  trap "" EXIT
  if [ -e ./config.sh ]; then
    echo "Limpiando agente..."
    while ! ./config.sh remove --unattended --auth "PAT" --token "$(cat "${AZP_TOKEN_FILE}")"; do
      echo "Reintentando en 30 s..."
      sleep 30
    done
  fi
}

# Cabeceras de color
print_header() {
  echo -e "\n\033[1;36m$1\033[0m\n"
}

# Ignorar ciertas variables en ejecución
export VSO_AGENT_IGNORE="AZP_TOKEN,AZP_TOKEN_FILE"

print_header "1. Descubriendo paquete de agente..."
AZP_AGENT_PACKAGES=$(curl -LsS \
    -u user:$(cat "${AZP_TOKEN_FILE}") \
    -H "Accept:application/json" \
    "${AZP_URL}/_apis/distributedtask/packages/agent?platform=${TARGETARCH}&top=1")
AZP_AGENT_PACKAGE_LATEST_URL=$(echo "${AZP_AGENT_PACKAGES}" | jq -r ".value[0].downloadUrl")

print_header "2. Descargando y extrayendo agente..."
curl -LsS "${AZP_AGENT_PACKAGE_LATEST_URL}" | tar -xz

source ./env.sh
trap "cleanup; exit 0" EXIT INT TERM

print_header "3. Configurando agente..."
./config.sh --unattended \
  --agent "${AZP_AGENT_NAME:-$(hostname)}" \
  --url "${AZP_URL}" \
  --auth "PAT" \
  --token "$(cat "${AZP_TOKEN_FILE}")" \
  --pool "${AZP_POOL:-Default}" \
  --work "${AZP_WORK:-_work}" \
  --replace \
  --acceptTeeEula

print_header "4. Ejecutando agente..."
chmod +x ./run.sh
./run.sh "$@"
