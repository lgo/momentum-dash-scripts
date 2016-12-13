#!/bin/bash
set -e

LINUX_CHROME_EXTENSION_PATH="$HOME/.config/chromium/Default/Extensions"
OSX_CHROME_EXTENSION_PATH="$HOME/Library/Application\ Support/Google/Chrome/Default/Extensions"

# Get proper Chrome extension folder from OS
case "$OSTYPE" in
  linux*)  CHROME_USER_FOLDER=$LINUX_CHROME_EXTENSION_PATH ;;
  darwin*)   CHROME_USER_FOLDER=$OSX_CHROME_EXTENSION_PATH ;;
  *)        echo "unknown os: $OSTYPE" ;;
esac



EXTENSION_ID=laookkfknpbbblfpciffpaejjkokdgca
MOMENTUM_VERSION=$(ls "${CHROME_USER_FOLDER}/${EXTENSION_ID}" | awk '{print $NF}' | tail -n1)
MOMENTUM_PATH=${CHROME_USER_FOLDER}/${EXTENSION_ID}/${MOMENTUM_VERSION}

if [ $# -eq 0 ]; then
    echo "Usage: $0 <scriptname> ..."
    echo ""
    echo "          installs a momentum dashboard script"
    exit 1
fi

# Check that the desired script exists
for scriptname in "$@"; do
  if ! [[ -d scripts/${scriptname} ]]; then
    echo "Script ${scriptname} does not exist" >&2;
    exit 1
  fi
done

# For each script
for scriptname in "$@"; do

  # Copy script files over
  rsync -rv --exclude=script.json scripts/${scriptname}/ "${MOMENTUM_PATH}" 1>/dev/null

  # If script defines CSS, insert CSS elements
  if [[ -d scripts/${scriptname}/css ]]; then
    for cssFile in $(ls scripts/$scriptname/css/*.css 2>/dev/null | xargs -n 1 basename) ; do
      if ! grep -F "<link rel=\"stylesheet\" href=\"css/${cssFile}\">" "${MOMENTUM_PATH}"/dashboard.html 1>/dev/null; then
        sed -i "\|<link rel=\"stylesheet\" href=\"css/style.min.css\">|a <link rel=\"stylesheet\" href=\"css/${cssFile}\">" "${MOMENTUM_PATH}"/dashboard.html
      fi
    done
  fi

  # If script defines JS, insert JS elements
  if [[ -d scripts/${scriptname}/js ]]; then
    for jsFile in $(ls scripts/$scriptname/js/*.js 2>/dev/null | xargs -n 1 basename) ; do
      if ! grep -F "<script src=\"js/${jsFile}\"></script>" "${MOMENTUM_PATH}"/dashboard.html 1>/dev/null; then
        sed -i "\|<script src=\"app/app.min.js\"></script>|a <script src=\"js/${jsFile}\"></script>" "${MOMENTUM_PATH}"/dashboard.html
      fi
    done
  fi

  # Add momemntum-script meta tag to denote that a script has been installed
  if ! grep -F "${scriptname}" "${MOMENTUM_PATH}"/dashboard.html 1>/dev/null; then
    sed -i "\|<title>New Tab</title>|a <meta name=\"installed-script\" content=\"$scriptname\">" "${MOMENTUM_PATH}"/dashboard.html
    echo "Installed $scriptname"
  else
    echo "Updated $scriptname"
  fi
done
