FROM alpine:latest AS build

RUN apk update && \
    apk add --no-cache \
        build-base=0.5-r3 \
        asio-dev=1.28.0-r0 \
        zlib-dev=1.3.1-r0 \
        git \
        cmake \
        pkgconf \
        openssl-dev

WORKDIR /CoolProxyWorkDir
RUN git clone https://github.com/libcpr/cpr.git && \
    cd cpr && \
    mkdir build && cd build && \
    cmake .. && make && make install

COPY src/ ./src/

WORKDIR /CoolProxyWorkDir/build

# Compile using g++
RUN g++ -o main ../src/main.cpp -lcpr -lpthread -O3 -DCROW_ENABLE_DEBUG -DCROW_ENABLE_COMPRESSION -lz -DCROW_ENABLE_SSL -lssl -lcrypto

RUN ldconfig /usr/lib
RUN ls /usr/lib
# Final Stage
FROM alpine:latest

RUN apk --no-cache add libstdc++ libgcc libcrypto3 libressl-dev zlib

WORKDIR /app

RUN addgroup -S coolman && adduser -S coolman -G coolman
USER coolman

COPY --from=build /CoolProxyWorkDir/build/main ./app/

EXPOSE 18080
ENTRYPOINT [ "./app/main" ]
