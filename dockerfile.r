FROM r-base:4.1.3

COPY ./filter /app/filter

WORKDIR /app

RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    r-cran-xml \
    r-cran-httr \
    libcairo2-dev \
    build-essential \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libtiff-dev

COPY requirements.r /app/

RUN Rscript requirements.r


CMD ["R"]