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
export COMMIT="\${3:-main}"

cat > ./.ghcrip.gitignore << EOF
*.bstate
*.temp
*.ghcrip
EOF

export TEMP_DIR="$(pwd)/.ghcrip/$(echo \${REPO} | awk -F// '{print $NF}')"
if test -d \$TEMP_DIR; then
    echo "Using cached repo." >> \${TEMP_DIR}/script.log 2>&1
else
    mkdir -p \$TEMP_DIR
    git clone \$REPO \$TEMP_DIR  >> \${TEMP_DIR}/script.log 2>&1
fi

echo "Checking out..." >> \${TEMP_DIR}/script.log
git -C \$TEMP_DIR checkout \${COMMIT} >> \${TEMP_DIR}/script.log 2>&1
git -C \$TEMP_DIR pull >> \${TEMP_DIR}/script.log 2>&1
/bin/bash \$TEMP_DIR/\$EXECUTABLE "\$@"
EOT

chmod -R 755 $GHCR_DIR