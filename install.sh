#!/bin/bash
export GHCR_DIR=$HOME/.ghcrip
mkdir -p $GHCR_DIR

cat > ~/.bash_profile <<EOF
export PATH="$GHCR_DIR:$PATH"
EOF
source ~/.bash_profile

cat > ~/.bashrc <<EOF
export PATH="$GHCR_DIR:$PATH"
EOF
source ~/.bashrc

cat > $GHCR_DIR/ghcrip <<EOT
set -e

export UUID=$(uuidgen)
export REPO="\$1"
export EXECUTABLE="\$2"

if ! test -f .gitignore  || ! grep -q -e "*.bstate" -e "*.temp" -e "*.ghcrip" ".gitignore" ; then
cat > ./.gitignore << EOF
*.bstate
*.temp
*.ghcrip
EOF
fi

export TEMP_DIR="${GHCR_DIR}/.ghcrip/\$(echo \${REPO} | awk -F// '{print \$NF}')"
export LOG_DIR="${GHCR_DIR}/.ghcrip/.log/\$(echo \${REPO} | awk -F// '{print \$NF}')"

if ! test -d \$LOG_DIR; then
    mkdir -p \$LOG_DIR
fi

if test -d \$TEMP_DIR; then
    echo "Using cached repo." >> \${LOG_DIR}/script.log 2>&1
else
    mkdir -p \$TEMP_DIR
    git clone \$REPO \$TEMP_DIR  >> \${LOG_DIR}/script.log 2>&1
fi

echo "Checking out..." >> \${LOG_DIR}/script.log
git -C \$TEMP_DIR checkout main >> \${LOG_DIR}/script.log 2>&1
git -C \$TEMP_DIR pull >> \${LOG_DIR}/script.log 2>&1
/bin/bash \$TEMP_DIR/\$EXECUTABLE "\${@:3}"
EOT

chmod -R 755 $GHCR_DIR