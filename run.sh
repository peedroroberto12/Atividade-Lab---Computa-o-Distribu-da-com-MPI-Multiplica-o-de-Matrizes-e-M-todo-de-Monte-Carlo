#!/bin/bash
# Copia um script para os 4 nos do cluster e executa via mpirun.
#
# Uso:  ./run.sh exercicio1.py 600


ARQUIVO=$1
N=$2

if [ -z "$ARQUIVO" ]; then
  echo "uso: ./run.sh <arquivo.py> [N]"
  exit 1
fi

for no in master worker1 worker2 worker3; do
  docker cp "$ARQUIVO" "$no":/home/mpiuser/ > /dev/null
done

docker compose exec master su - mpiuser -c \
  "mpirun --hostfile hosts --map-by node -np 4 python3 $ARQUIVO $N"
