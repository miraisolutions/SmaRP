#!/bin/bash

# Retrieve the list of packages to re-install them later
TL_INSTALLED_PKGS=$(tlmgr info --list --only-installed --data name | tr '\n' ' ')
# Uninstall TinyTeX
tlmgr path remove
rm -r /opt/TinyTeX
# Then reinstall TinyTeX including packages
sh install_tinytex.sh $TL_INSTALLED_PKGS
