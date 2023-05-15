#!/bin/bash
if [ -z "$1" ]
  then
      cat <<EOF

usage: $0 VALIDATOR_VOTE_PUBKEY STAKE_AMOUNT [RPC_URL]

Stake a validator

VALIDATOR_VOTE_PUBKEY could be found by command \`solana validators\`
STAKE_AMOUNT should be integer on number of sols to stake
RPC_URL will be defaulted to http://127.0.0.1:8899

Stakes will be updated when epoch ends.

EOF
  exit 1
fi

VALIDATOR_VOTE_PUBKEY=$1
STAKE_AMOUNT=$2
if ! [[ "$STAKE_AMOUNT" =~ ^[0-9]+$ ]]
    then
        echo "Sorry integers only"
        exit 1
fi

rpc_url=$3
if [[ -z $rpc_url ]]; then
rpc_url="http://127.0.0.1:8899"
fi

solana-keygen new --no-passphrase -o random_user.json

USER=$(solana address -k random_user.json)
solana transfer $USER $STAKE_AMOUNT -k faucet.json -u $rpc_url --allow-unfunded-recipient

solana-keygen new --no-passphrase -o tmp.json
solana create-stake-account tmp.json $STAKE_AMOUNT -k random_user.json -u $rpc_url
stake_addr=$(solana address -k tmp.json)
rm tmp.json

echo "staking to $VALIDATOR_VOTE_PUBKEY"

solana delegate-stake $stake_addr $VALIDATOR_VOTE_PUBKEY -k random_user.json -u $rpc_url

echo "stakes will be valid after"
solana epoch-info