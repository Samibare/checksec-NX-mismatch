FROM ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y binutils git bash gcc golang-go

WORKDIR /nx-mismatch

RUN git clone https://github.com/slimm609/checksec.git checksec-main-269453e \
    && cd checksec-main-269453e \
    && git checkout 269453e \
    && cp checksec.bash /usr/local/bin/checksec-Bash-269453e \
    && go build -o /usr/local/bin/checksec-Go-269453e 

RUN git clone https://github.com/slimm609/checksec.git checksec-latest-71012bf \
    && cd checksec-latest-71012bf \
    && git checkout 71012bf \
    && go build -o /usr/local/bin/checksec-Go-latest-71012bf

RUN git clone https://github.com/slimm609/checksec.git checksec-apt-bash-2753ebb \
    && cd checksec-apt-bash-2753ebb \
    && git checkout 2753ebb \
    && cp checksec /usr/local/bin/checksec-Bash-apt-2753ebb

COPY . /nx-mismatch

RUN chmod +x ./runByBuilds.sh \
    && chmod +x ./runByTest.sh



