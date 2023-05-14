#!/bin/bash

mkdir bootstrap-validator
solana-keygen new --no-passphrase -o bootstrap-validator/identity.json
solana-keygen new --no-passphrase -o bootstrap-validator/vote.json
solana-keygen new --no-passphrase -o bootstrap-validator/withdrawer.json
solana-keygen new --no-passphrase -o bootstrap-validator/stake.json

echo "creating genesis block"

solana-genesis \
    --max-genesis-archive-unpacked-size 1073741824 \
    --enable-warmup-epochs \
    --bootstrap-validator bootstrap-validator/identity.json bootstrap-validator/vote.json bootstrap-validator/stake.json \
    --bpf-program TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA BPFLoader2111111111111111111111111111111111 programs/spl_token-3.5.0.so \
    --bpf-program TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb BPFLoaderUpgradeab1e11111111111111111111111 programs/spl_token-2022-0.6.0.so \
    --bpf-program Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo BPFLoader1111111111111111111111111111111111 programs/spl_memo-1.0.0.so \
    --bpf-program MemoSq4gqABAXKb96qnH8TysNcWxMyWCqXgDLGmfcHr BPFLoader2111111111111111111111111111111111 programs/spl_memo-3.0.0.so \
    --bpf-program ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL BPFLoader2111111111111111111111111111111111 programs/spl_associated-token-account-1.1.2.so \
    --bpf-program Feat1YXHhH6t1juaWF74WLcfv4XoNocjXA6sPWHNgAse BPFLoader2111111111111111111111111111111111 programs/spl_feature-proposal-1.0.0.so \
    --ledger bootstrap-validator/ledger \
    --faucet-pubkey faucet.json \
    --faucet-lamports 500000000000000000 \
    --hashes-per-tick auto \
    --slots-per-epoch 500 \
    --bootstrap-validator-stake-lamports 500000000000000 \
    --cluster-type development
