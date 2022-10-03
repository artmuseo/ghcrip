#!/bin/bash

# install ghcrip
curl https://raw.githubusercontent.com/artmuseo/ghcrip/main/install.sh | bash
export GHCR_DIR=$HOME/.ghcrip

cat > $GHCR_DIR/ab <<EOF
set -e
export EXECUTABLE="\$1"
ghcrip https://github.com/artmuseo/util \${EXECUTABLE}/\${EXECUTABLE}.sh \${@:1}
EOF

chmod -R 755 $GHCR_DIR