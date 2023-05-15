#!/bin/bash
if [ -z "$1" ]
  then
      cat <<EOF

usage: $0 ID [cluster entry point hostname] [solana validator arguments]

Start a validator with no stake

Will create a new validator in folder validator_{ID}
Cluster entry point name will be defaulted to [127.0.0.1] and 
gossip portrange will be defaulted to [8000 + 100 * {ID} - 8000 + 100 * {ID} + 50 ]

EOF
  exit 1
fi


ID=$1
if ! [[ "$ID" =~ ^[0-9]+$ ]]
    then
        echo "Sorry integers only"
        exit 1
fi

VALIDATOR_DIR=validator_$ID
mkdir validator
solana-keygen new --no-passphrase -o $VALIDATOR_DIR/identity.json
solana-keygen new --no-passphrase -o $VALIDATOR_DIR/vote.json
solana-keygen new --no-passphrase -o $VALIDATOR_DIR/withdrawer.json
solana-keygen new --no-passphrase -o $VALIDATOR_DIR/stake.json
solana-keygen new --no-passphrase -o random_user.json

entrypoint_hostname="$2"
echo "host : $entrypoint_hostname"
if [[ -z $entrypoint_hostname ]]; then
gossip_entrypoint=127.0.0.1:8001
let start_port=8000+$ID\*100
let end_port=8000+$ID\*100+50
dynamic_port_range=$"$start_port-$end_port"
let RPC_PORT_VALUE=8899-$ID
RPC_PORT=$RPC_PORT_VALUE
else
gossip_entrypoint="$entrypoint_hostname":8001
dynamic_port_range="8001-8050"
RPC_PORT=8899
fi
echo "gossip : $gossip_entrypoint port range $dynamic_port_range"

rpc_url=$(solana-gossip --allow-private-addr rpc-url --timeout 180 --entrypoint "$gossip_entrypoint")
echo "rpc : $rpc_url"

echo "Moving 1000 SOLs to new solana identity"

solana transfer --keypair faucet.json \
  --url $rpc_url \
  --allow-unfunded-recipient $VALIDATOR_DIR/identity.json 1000

echo "Moving 100000 SOLs to a random user"

solana transfer --keypair faucet.json \
  --url $rpc_url \
  --allow-unfunded-recipient \
  random_user.json 100000

echo "Creating vote account for the validator"

solana create-vote-account \
    --keypair $VALIDATOR_DIR/identity.json \
    --url $rpc_url \
    $VALIDATOR_DIR/vote.json $VALIDATOR_DIR/identity.json $VALIDATOR_DIR/withdrawer.json

echo "Staring the validator"

rm $VALIDATOR_DIR/log.txt

solana-validator \
    --max-genesis-archive-unpacked-size 1073741824 \
    --no-poh-speed-test \
    --no-os-network-limits-test \
    --entrypoint "$gossip_entrypoint" \
    --identity $VALIDATOR_DIR/identity.json \
    --vote-account $VALIDATOR_DIR/vote.json \
    --ledger $VALIDATOR_DIR/ledger \
    --log $VALIDATOR_DIR/log.txt \
    --full-rpc-api \
    --no-incremental-snapshots \
    --require-tower \
    --rpc-port $RPC_PORT \
    --dynamic-port-range $dynamic_port_range \
    "${@:3}" &


