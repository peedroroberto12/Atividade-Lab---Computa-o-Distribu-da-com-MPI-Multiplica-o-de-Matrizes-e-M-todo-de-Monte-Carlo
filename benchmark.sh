#!/bin/bash
# Roda as 3 versoes (sequencial, threads, MPI distribuido) para cada N
# e imprime a tabela de desempenho do Exercicio 1.
#
# Uso:  ./benchmark.sh            -> roda N = 300, 600 e 1000
#       ./benchmark.sh 300 600    -> roda so os N informados
#
# Os resultados tambem sao gravados em resultados.txt.

set -u

NS=${@:-"300 600 1000"}
SAIDA="resultados.txt"


extrai_ms() {
  grep -oE '[0-9]+\.[0-9]+' | tail -1
}

declare -A R

echo "Iniciando benchmark. Os N maiores demoram alguns minutos."
echo

for N in $NS; do
  echo "--- N = $N ---"

  echo -n "  sequencial ... "
  t=$( { python3 sequencial.py "$N"; } 2>&1 | extrai_ms )
  R["$N,seq"]=${t:-ERRO}
  echo "${t:-ERRO} ms"

  echo -n "  threads ...... "
  t=$( { python3 threads.py "$N"; } 2>&1 | extrai_ms )
  R["$N,thr"]=${t:-ERRO}
  echo "${t:-ERRO} ms"

  echo -n "  MPI .......... "
  for no in master worker1 worker2 worker3; do
    docker cp exercicio1.py "$no":/home/mpiuser/ > /dev/null 2>&1
  done
  t=$( docker compose exec master su - mpiuser -c \
        "mpirun --hostfile hosts --map-by node -np 4 python3 exercicio1.py $N" \
        2>&1 | extrai_ms )
  R["$N,mpi"]=${t:-ERRO}
  echo "${t:-ERRO} ms"
  echo
done

# ---- tabela final ---------------------------------------------------------
{
  echo
  echo "======================================================================"
  echo "  Exercicio 1 - Multiplicacao de matrizes | tempos em ms"
  echo "======================================================================"
  printf "  %-8s %14s %14s %14s\n" "N" "Sequencial" "Threads" "MPI (4 nos)"
  echo "  --------------------------------------------------------------"
  for N in $NS; do
    printf "  %-8s %14s %14s %14s\n" \
      "$N" "${R[$N,seq]}" "${R[$N,thr]}" "${R[$N,mpi]}"
  done
  echo "======================================================================"
  echo "  Gerado em $(date '+%d/%m/%Y %H:%M')  |  nproc = $(nproc)"
  echo "======================================================================"
} | tee "$SAIDA"

echo
echo "Tabela salva em $SAIDA"
