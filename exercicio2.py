import sys
from mpi4py import MPI

comm = MPI.COMM_WORLD
rank = comm.Get_rank()
size = comm.Get_size()

N = int(sys.argv[1]) if len(sys.argv) > 1 else 10_000_000
n_local = N // size

import random

dentro_local = 0
comm.Barrier()
t0 = MPI.Wtime()
for _ in range(n_local):
    x = random.random()
    y = random.random()
    if x * x + y * y <= 1.0:
        dentro_local += 1

dentro_total = comm.reduce(dentro_local, op=MPI.SUM, root=0)
t_fim = MPI.Wtime()

if rank == 0:
    pi = 4.0 * dentro_total / N
    print(f"PI ≈ {pi:.6f} | tempo: {(t_fim - t0) * 1000:.2f} ms")