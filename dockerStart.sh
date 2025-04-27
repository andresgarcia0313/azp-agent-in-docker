docker build --tag azp-agent:linux --file Dockerfile .
#            --interactive --tty \
docker run -d \
  --name azp-agent-linux \
  --restart unless-stopped \
  -e AZP_URL="https://dev.azure.com/andresgarcia0313" \
  -e AZP_TOKEN="" \
  -e AZP_POOL="nexo-pool" \
  -e AZP_AGENT_NAME="nexo-pool-linux-agent-docker" \
  azp-agent:linux

docker run -d \
  --name azp-agent-linux2 \
  --restart unless-stopped \
  -e AZP_URL="https://dev.azure.com/andresgarcia0313" \
  -e AZP_TOKEN="" \
  -e AZP_POOL="nexo-pool" \
  -e AZP_AGENT_NAME="nexo-pool-linux-agent-docker2" \
  azp-agent:linux