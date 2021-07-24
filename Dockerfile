FROM ubuntu:20.04 AS builder
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git autoconf automake autotools-dev curl python3 libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev
RUN git clone https://github.com/riscv/riscv-gnu-toolchain && \
    git clone https://github.com/qemu/qemu
RUN cd riscv-gnu-toolchain && ./configure --prefix=/opt/riscv && make -j2
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install ninja-build libglib2.0-dev libpixman-1-dev
RUN cd qemu && ./configure --target-list=riscv64-softmmu && make -j2 && make install

FROM ubuntu:20.04
RUN apt-get -y update
COPY --from=builder /opt/riscv /opt/riscv
COPY --from=builder /qemu/build /qemu/build
RUN echo 'export PATH=$PATH:/opt/riscv/bin:/qemu/build' >> ~/.bashrc
RUN apt-get -y update && apt-get -y install libmpc-dev libpixman-1-dev vim make libglib2.0 && rm -rf /var/lib/apt/lists/*
WORKDIR /os
