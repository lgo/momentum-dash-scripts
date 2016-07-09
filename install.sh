#!/bin/bash
set -e

case "$OSTYPE" in
  linux*)  CHROME_USER_FOLDER="~/.config/chromium/Default/Extensions" ;; 
  darwin*)   CHROME_USER_FOLDER="~/Library/Application\ Support/Google/Chrome/Default/Extensions" ;;
  *)        echo "unknown: $OSTYPE" ;;
esac



EXTENSIONS_FOLDER=${CHROM_USER_FOLDER}
EXTENSION_ID=laookkfknpbbblfpciffpaejjkokdgca
MOMENTUM_VERSION=$(ls ${CHROME_USER_FOLDER}/${EXTENSION_ID} | awk '{print $NF}' | tail -n1)
MOMENTUM_PATH=${CHROME_USER_FOLDER}/${EXTENSION_ID}/${MOMENTUM_VERSION}

for scriptname in "$@"; do
  if ! [[ -d scripts/${scriptname} ]]; then
    echo "Script ${scriptname} does not exist" >&2;
    exit 1
  fi
done

for scriptname in "$@"; do
  rsync -rv --exclude=script.json scripts/${scriptname}/ ${MOMENTUM_PATH} 1>/dev/null
  if [[ -d scripts/${scriptname}/css ]]; then
    for cssFile in $(ls scripts/$scriptname/css/*.css 2>/dev/null | xargs -n 1 basename) ; do
      if ! grep -F "<link rel=\"stylesheet\" href=\"css/${cssFile}\">" ${MOMENTUM_PATH}/dashboard.html 1>/dev/null; then
        sed -i "\|<link rel=\"stylesheet\" href=\"css/style.min.css\">|a <link rel=\"stylesheet\" href=\"css/${cssFile}\">" ${MOMENTUM_PATH}/dashboard.html
      fi
    done
  fi

  if [[ -d scripts/${scriptname}/js ]]; then
    for jsFile in $(ls scripts/$scriptname/js/*.js 2>/dev/null | xargs -n 1 basename) ; do
      if ! grep -F "<script src=\"js/${jsFile}\"></script>" ${MOMENTUM_PATH}/dashboard.html 1>/dev/null; then
        sed -i "\|<script src=\"app/app.min.js\"></script>|a <script src=\"js/${jsFile}\"></script>" ${MOMENTUM_PATH}/dashboard.html
      fi
    done
  fi
  if ! grep -F "${scriptname}" ${MOMENTUM_PATH}/dashboard.html 1>/dev/null; then
    sed -i "\|<title>New Tab</title>|a <meta name=\"installed-script\" content=\"$scriptname\">" ${MOMENTUM_PATH}/dashboard.html
    echo "Installed $scriptname"
  else
    echo "Updated $scriptname"
  fi
done
