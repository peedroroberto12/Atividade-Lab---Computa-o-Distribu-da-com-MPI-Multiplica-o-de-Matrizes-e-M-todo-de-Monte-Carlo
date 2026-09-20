#!/bin/bash
set -e

echo "1/3 Gerando a chave no master..."
docker compose exec -T master bash -c '
  mkdir -p /home/mpiuser/.ssh
  if [ ! -f /home/mpiuser/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 2048 -N "" -f /home/mpiuser/.ssh/id_rsa
  fi
  chown -R mpiuser:mpiuser /home/mpiuser/.ssh
  chmod 700 /home/mpiuser/.ssh
'


PUBKEY=$(docker compose exec -T master cat /home/mpiuser/.ssh/id_rsa.pub)

echo "2/3 Autorizando a chave em cada no..."
for node in master worker1 worker2 worker3; do
  echo "  -> $node"
  echo "$PUBKEY" | docker compose exec -T "$node" bash -c '
    mkdir -p /home/mpiuser/.ssh
    cat > /home/mpiuser/.ssh/authorized_keys
    printf "Host *\n    StrictHostKeyChecking no\n    UserKnownHostsFile /dev/null\n" \
      > /home/mpiuser/.ssh/config
    chown -R mpiuser:mpiuser /home/mpiuser/.ssh
    chmod 700 /home/mpiuser/.ssh
    chmod 600 /home/mpiuser/.ssh/authorized_keys /home/mpiuser/.ssh/config
  '
done

echo "3/3 Criando o hostfile no master..."
docker compose exec -T master bash -c '
  printf "master slots=2\nworker1 slots=2\nworker2 slots=2\nworker3 slots=2\n" \
    > /home/mpiuser/hosts
  chown mpiuser:mpiuser /home/mpiuser/hosts
'

echo
echo "SSH configurado. Teste com:"
echo '  docker compose exec master su - mpiuser -c "mpirun --hostfile hosts --map-by node -np 4 hostname"'
