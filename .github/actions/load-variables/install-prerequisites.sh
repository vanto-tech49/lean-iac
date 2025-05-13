#!/bin/bash

# fail on error
set -e

scriptRoot=$(dirname "$0")

echo "Install yq..."
wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && chmod a+x /usr/local/bin/yq