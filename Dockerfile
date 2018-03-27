FROM rocker/r-ver:3.4.4

MAINTAINER Nicola Lambiase "nicola.lambiase@mirai-solutions.com"

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
    dplyr \
    googleVis \
    kableExtra \
    lubridate \
    magrittr \
    pander \
    rmarkdown \
    shiny \
    shinyBS \
    shinythemes \
    webshot

# copy the app to the image
RUN mkdir /root/SmaRP
COPY . /root/SmaRP

# set host and port
RUN echo "options(shiny.port = 3838, shiny.host = '0.0.0.0')" >> /usr/local/lib/R/etc/Rprofile.site
# install PhantomJS
RUN R -e "library(webshot); webshot::install_phantomjs()"

EXPOSE 3838

CMD ["R", "-e", "shiny::runApp('/root/SmaRP')"]
