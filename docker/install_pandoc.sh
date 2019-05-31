#!/bin/bash

# Required dependencies:
# - wget (at build time)

## Install recebt pandoc <https://pandoc.org/installing.html#linux>
wget -q https://github.com/jgm/pandoc/releases/download/$1 \
&& dpkg -i $(basename $1) \
&& rm $(basename $1)
