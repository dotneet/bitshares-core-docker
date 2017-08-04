FROM ubuntu:16.04
LABEL maintainer "Shinji Yamada <dotneet@gmail.com>"

RUN apt-get update -y
RUN apt-get install -y wget gcc g++ make automake autoconf cmake git libtool libboost-all-dev libssl-dev

RUN wget https://www.openssl.org/source/openssl-1.0.2l.tar.gz && \
    tar zxf openssl-1.0.2l.tar.gz && \
    cd openssl-1.0.2l && \
    CFLAGS=-fPIC ./config shared --prefix=/usr/local/openssl-1.0 && \
    make install

RUN git clone https://github.com/bitshares/bitshares-core.git /bitshares
WORKDIR /bitshares
RUN git checkout 2.0.170710 && git submodule update --init --recursive

RUN cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DOPENSSL_INCLUDE_DIR=/usr/local/openssl-1.0/include \
    -DOPENSSL_SSL_LIBRARY=/usr/local/openssl-1.0/lib/libssl.so \
    -DOPENSSL_CRYPTO_LIBRARY=/usr/local/openssl-1.0/lib/libcrypto.so .

RUN make

RUN mkdir /data_dir
VOLUME /data_dir

EXPOSE 8090 9090

CMD ["/bitshares/programs/witness_node/witness_node", "--data-dir", "/data_dir"]

