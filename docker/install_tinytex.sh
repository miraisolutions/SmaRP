#!/bin/bash

# Required dependencies:
# - wget (at build time)
# - texinfo (for TinyTeX)
# - ghostscript (for pdfcrop)

## Install TinyTeX from date-locked CTAN tlnet archive. This is inspired by
## rocker/r-ver, and the TZ is probably still fine in this context
[ -z "$CTAN_DATE" ] && CTAN_DATE=$(TZ="America/Los_Angeles" date +%Y/%m/%d) || true \
&& CTAN_REPO=https://www.texlive.info/tlnet-archive/${CTAN_DATE}/tlnet \
&& export CTAN_REPO

## Admin-based install of TinyTeX:
install2.r --error --skipinstalled tinytex \
&& wget -qO- \
  "https://github.com/yihui/tinytex/raw/master/tools/install-unx.sh" | \
  sh -s - --admin --no-path \
&& mv ~/.TinyTeX /opt/TinyTeX \
&& /opt/TinyTeX/bin/*/tlmgr path add
## LaTeX packages from rocker/verse and app-specific packages passed as arguments
tlmgr install \
  ae inconsolata listings metafont mfware pdfcrop parskip tex \
  "$@"\
&& tlmgr path add \
&& Rscript -e "tinytex::r_texmf()"

chown -R root:staff /opt/TinyTeX \
&& chmod -R g+w /opt/TinyTeX \
&& chmod -R g+wx /opt/TinyTeX/bin
