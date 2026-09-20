import random
from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

import sys
N = int(sys.argv[1]) if len(sys.argv) > 1 else 300

if rank == 0:
    A = [[random.random() for _ in range(N)] for _ in range(N)]
    B = [[random.random() for _ in range(N)] for _ in range(N)]
else:
    A = None
    B = None

comm.Barrier()
t0 = MPI.Wtime()
A = comm.bcast(A, root=0)
B = comm.bcast(B, root=0)

linhas_por_processo = N // size
linha_ini = rank * linhas_por_processo
linha_fim = linha_ini + linhas_por_processo

bloco_local = []
for i in range(linha_ini, linha_fim):
    linha_C = []
    for j in range(N):
        soma = 0.0
        for k in range(N):
            soma += A[i][k] * B[k][j]
        linha_C.append(soma)
    bloco_local.append(linha_C)

blocos = comm.gather(bloco_local, root=0)
t_fim = MPI.Wtime()

if rank == 0:
    C = []
    for bloco in blocos:
        C.extend(bloco)
    soma_C = sum(sum(linha) for linha in C)
    print(f"N = {N} | C acumulado: {soma_C:.4f} | tempo: {(t_fim - t0) * 1000:.2f} ms")

