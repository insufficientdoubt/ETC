#!/usr/bin/env sh
set -e

echo "Generating 32-byte hex secrets..."
OUT1=$(openssl rand -hex 32)
OUT2=$(openssl rand -hex 32)
echo "OUTLINE_SECRET_KEY=$OUT1"
echo "OUTLINE_UTILS_SECRET=$OUT2"

