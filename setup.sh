#!/bin/bash

sudo apt update -y
sudo apt install build-essential pkg-config libssl-dev git-all protobuf-compiler git screen -y

curl https://sh.rustup.rs -sSf | sh -s -- -y
export PATH="$HOME/.cargo/bin:$PATH"

PROVER_ID=$1
NEXUS_HOME=$HOME/.nexus
GREEN='\033[1;32m'
ORANGE='\033[1;33m'
NC='\033[0m' # No Color

mkdir $NEXUS_HOME
echo "$PROVER_ID" > $NEXUS_HOME/prover-id

REPO_PATH=$NEXUS_HOME/network-api
if [ -d "$REPO_PATH" ]; then
  echo "$REPO_PATH exists. Updating.";
  (cd $REPO_PATH && git stash save && git fetch --tags)
else
  mkdir -p $NEXUS_HOME
  (cd $NEXUS_HOME && git clone https://github.com/nexus-xyz/network-api)
fi
(cd $REPO_PATH && git -c advice.detachedHead=false checkout $(git rev-list --tags --max-count=1))

screen -dmS "nexus" bash -c "cd $REPO_PATH/clients/cli && cargo run --release --bin prover -- beta.orchestrator.nexus.xyz && exec bash"