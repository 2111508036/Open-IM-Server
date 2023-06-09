FROM golang as build

# go mod Installation source, container environment variable addition will override the default variable value
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct

# Set up the working directory
WORKDIR /Open-IM-Server

# add all files to the container
COPY . .

RUN chmod +x /Open-IM-Server/script/*.sh && \
    /bin/sh -c /Open-IM-Server/script/build_all_service.sh

#Blank image Multi-Stage Build
FROM alpine

RUN apk add --no-cache vim curl tzdata gawk procps net-tools

#Time zone adjusted to East eighth District
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

#set directory to map logs,config file,script file.
VOLUME ["/Open-IM-Server/logs","/Open-IM-Server/config","/Open-IM-Server/script","/Open-IM-Server/db/sdk"]

#Copy script files and binary files to the blank image
COPY --from=build --chown=root:root /Open-IM-Server/script /Open-IM-Server/script
COPY --from=build --chown=root:root /Open-IM-Server/bin /Open-IM-Server/bin

WORKDIR /Open-IM-Server/script

CMD ["/Open-IM-Server/script/docker_start_all.sh"]
