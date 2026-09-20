FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && \
    apt install -y openmpi-bin libopenmpi-dev openssh-server sudo figlet net-tools iputils-ping \
                   python3 python3-pip python3-mpi4py && \
    useradd -m -s /bin/bash mpiuser && \
    echo "mpiuser:mpi123" | chpasswd && \
    adduser mpiuser sudo && \
    mkdir /var/run/sshd

EXPOSE 22
CMD service ssh start && sleep infinity
