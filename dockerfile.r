FROM r-base:4.1.3

COPY ./filter /app/filter

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev -y \
    libssl-dev -y \
    libxml2-dev -y \
    r-cran-xml -y \
    r-cran-httr -y \
    libcairo2-dev -y \
    build-essential -y \
    libcurl4-gnutls-dev -y \
    libxml2-dev -y \
    libssl-dev -y \
    libharfbuzz-dev -y \
    libfribidi-dev -y \
    libtiff-dev

COPY requirements.r /app/

RUN Rscript requirements.r


CMD ["R"]