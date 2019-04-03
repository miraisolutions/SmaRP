FROM rocker/r-ver:3.5.1

RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libxml2-dev \
    texlive-full \
    wget \
    curl

# Install needed packages
RUN install2.r --error \
    bsplus \
    dplyr \
    ggplot2 \
    googleVis \
    htmltools \
    kableExtra \
    knitr \
    lubridate \
    magrittr \
    pander \
    reshape2 \
    rmarkdown \
    shiny \
    shinyWidgets


# copy the app to the image
RUN mkdir /root/SmaRP
COPY . /root/SmaRP

# set host and port
RUN echo "options(shiny.port = 80, shiny.host = '0.0.0.0')" >> /usr/local/lib/R/etc/Rprofile.site

# install SmaRP
RUN cd /root && \
    install2.r --repos NULL --error -- --no-multiarch --with-keep.source SmaRP

EXPOSE 80

CMD ["R", "-e", "library(SmaRP); SmaRP::launch_application()"]
