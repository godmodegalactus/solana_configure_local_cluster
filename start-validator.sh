#!/bin/bash

mkdir validator
solana-keygen new --no-passphrase -o validator/identity.json
solana-keygen new --no-passphrase -o validator/vote.json
solana-keygen new --no-passphrase -o validator/withdrawer.json
solana-keygen new --no-passphrase -o validator/stake.json
solana-keygen new --no-passphrase -o random_user.json

entrypoint_hostname="$1"
echo "host : $entrypoint_hostname"
if [[ -z $entrypoint_hostname ]]; then
gossip_entrypoint=127.0.0.1:8001
else
gossip_entrypoint="$entrypoint_hostname":8001
fi
echo "gossip : $gossip_entrypoint"

rpc_url=$(solana-gossip --allow-private-addr rpc-url --timeout 180 --entrypoint "$gossip_entrypoint")
echo "rpc : $rpc_url"

echo "Moving 1000 SOLs to new solana identity"

solana transfer --keypair faucet.json \
  --url $rpc_url \
  --allow-unfunded-recipient validator/identity.json 1000

echo "Moving 100000 SOLs to a random user"

solana transfer --keypair faucet.json \
  --url $rpc_url \
  --allow-unfunded-recipient \
  random_user.json 100000

echo "Creating vote account for the validator"

solana create-vote-account \
    --keypair validator/identity.json \
    --url $rpc_url \
    validator/vote.json validator/identity.json validator/withdrawer.json

echo "Staring the validator"

solana-validator \
    --max-genesis-archive-unpacked-size 1073741824 \
    --no-poh-speed-test \
    --no-os-network-limits-test \
    --entrypoint "$gossip_entrypoint" \
    --identity validator/identity.json \
    --vote-account validator/vote.json \
    --ledger validator/ledger \
    --log validator/log.txt \
    --full-rpc-api \
    --no-incremental-snapshots \
    --require-tower \
    "${@:2}" &


