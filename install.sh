#!/bin/bash

cat /usr/local/bin/ghcrip > <<EOT
set -e

export UUID=$(uuidgen)
export REPO="$1"
export EXECUTABLE="$2"
export COMMIT="${3:-main}"

cat > ./.ghcrip.gitignore << EOF
*.bstate
*.temp
*.ghcrip
EOF

export TEMP_DIR="$(pwd)/.ghcrip/$(echo ${REPO} | awk -F// '{print $NF}')"
if test -d $TEMP_DIR; then
    echo "Using cached repo." >> ${TEMP_DIR}/script.log 2>&1
else
    mkdir -p $TEMP_DIR
    git clone $REPO $TEMP_DIR  >> ${TEMP_DIR}/script.log 2>&1
fi

echo "Checking out..." >> ${TEMP_DIR}/script.log
git -C $TEMP_DIR checkout ${COMMIT} >> ${TEMP_DIR}/script.log 2>&1
git -C $TEMP_DIR pull >> ${TEMP_DIR}/script.log 2>&1
/bin/bash $TEMP_DIR/$EXECUTABLE

EOT
