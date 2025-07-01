# Exportar variables del .env (para que el script las reconozca)
set -o allexport; source .env; set +o allexport

# Calcular cuántos agentes están definidos
AGENT_COUNT=$(echo "$AGENT_NAMES" | tr ',' '\n' | wc -l)

# Levantar contenedores con nombre de host como AZP_AGENT_NAME
docker compose up -d --build --scale agent=$AGENT_COUNT
