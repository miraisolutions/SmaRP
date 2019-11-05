#!/bin/bash

# Required dependencies:
# - wget (at build time)
# - texinfo (for TinyTeX)
# - ghostscript (for pdfcrop)

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
