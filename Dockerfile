FROM rocker/r-ver:3.5.3

## Install recent pandoc version, required by rmarkdown
# - see https://github.com/rstudio/rmarkdown/blob/master/PANDOC.md
# - https://pandoc.org/installing.html#linux
# We should use the same version as in rocker/rstudio:<R_VER>
#   docker run --rm rocker/rstudio:<R_VER> /usr/lib/rstudio-server/bin/pandoc/pandoc -v
ENV PANDOC_DEB="2.3.1/pandoc-2.3.1-1-amd64.deb"

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ## For R package 'curl'
    libcurl4-gnutls-dev \
    ## For R package 'xml2'
    libxml2-dev \
    ## For R package 'openssl'
    libssl-dev \
    ## For manual install of recent 'pandoc' version
    wget \
    ## For TinyTex
    texinfo \
    ## For 'pdfcrop'
    ghostscript \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/ \
  ## Use TinyTeX for LaTeX installation
  && install2.r --error tinytex \
  ## Admin-based install of TinyTeX:
  && wget -qO- \
    "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
    sh -s - --admin --no-path \
  && mv ~/.TinyTeX /opt/TinyTeX \
  && /opt/TinyTeX/bin/*/tlmgr path add \
  && tlmgr install \
    ae inconsolata listings metafont mfware pdfcrop parskip tex \
    fancyhdr \
  && tlmgr path add \
  && Rscript -e "tinytex::r_texmf()" \
  && chown -R root:staff /opt/TinyTeX \
  && chown -R root:staff /usr/local/lib/R/site-library \
  && chmod -R g+w /opt/TinyTeX \
  && chmod -R g+wx /opt/TinyTeX/bin \
  ## Pandoc
  && wget -q https://github.com/jgm/pandoc/releases/download/$PANDOC_DEB \
  && dpkg -i $(basename $PANDOC_DEB) \
  && rm $(basename $PANDOC_DEB)

## Install major fixed R dependencies
#  - they will be always needed and we want them in a dedicated layer,
#    as opposed to geting them dinamically via `remotes::install_local()`
RUN install2.r --error \
  shiny \
  dplyr \
  rmarkdown

## Copy the app to the image
COPY . /tmp/SmaRP

# Install SmaRP
RUN install2.r --error remotes \
  && R -e "remotes::install_local('/tmp/SmaRP')" \
  && rm -R /tmp/SmaRP

# Set host and port
RUN echo "options(shiny.port = 80, shiny.host = '0.0.0.0')" >> /usr/local/lib/R/etc/Rprofile.site

EXPOSE 80

CMD ["R", "-e", "SmaRP::launch_application()"]
