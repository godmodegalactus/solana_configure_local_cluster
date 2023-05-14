echo "starting bootstrap validator"

solana-validator \
    --require-tower \
    --ledger bootstrap-validator/ledger \
    --rpc-port 8899 \
    --snapshot-interval-slots 200 \
    --no-incremental-snapshots \
    --identity bootstrap-validator/identity.json \
    --vote-account bootstrap-validator/vote.json \
    --rpc-faucet-address 127.0.0.1:9900 \
    --no-poh-speed-test \
    --no-os-network-limits-test \
    --no-wait-for-vote-to-start-leader \
    --full-rpc-api \
    --gossip-port 8001 \
    --allow-private-addr \
    --log bootstrap-validator/log.txt \
    --gossip-host 0.0.0.0 \
    "${@:0}" &

solana-faucet -k faucet.json &