FROM python:3.8-slim-buster

WORKDIR /app
COPY . .

RUN apt-get update && \
    apt-get install -y \
        vim \
        x11-apps \
        x11-xserver-utils \
        net-tools \
        wget \
        make \
        libsm6 \
        libice6 \
        libxpm4 \
        libx11-6 \
        libncurses5 \
        zlib1g-dev \
        build-essential && \
    pip3 install -r requirements.txt

# Docker RUN指令預設是用/bin/sh -c執行，但shell沒有source，所以這邊要改用bash
SHELL ["/bin/bash", "-c"]
RUN cd mseed2sac && \
    make && \
    mkdir ~/bin && \
    mv mseed2sac ~/bin && \
    echo "export PATH=$HOME/bin:$PATH" >> ~/.bashrc && \
    source ~/.bashrc

RUN tar -xzvf sac-101.5c-linux_x86_64.tar.gz && \
    sed -i 's#SACHOME=/usr/local/sac#SACHOME=/app/sac#' /app/sac/bin/sacinit.sh  && \
    sed -i 's#PATH=${PATH}:${SACHOME}/bin#PATH=${SACHOME}/bin:${PATH}#' /app/sac/bin/sacinit.sh  && \
    echo "source /app/sac/bin/sacinit.sh" >> ~/.bashrc && \
    source ~/.bashrc

CMD ["bash", "-c", "sleep infinity"]