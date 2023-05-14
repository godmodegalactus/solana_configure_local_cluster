# Solana Configure Local Cluster

This repo is dedicated to easily configure a solana private cluster.

This is for development purpose only and should not be used to configure production cluster.

We encourage you to contribute more scripts to this repository.

The cluster is created with epoch length of only 500 slots.

## Installation and requirements
Please install the required solana-cli version using this link (Solana-CLI)[https://docs.solana.com/cli/install-solana-cli-tools]

## Configuring bootstrap validator

* Run the following script:
```
./configure-bootstrap.sh
```

* Starting bootstrap validator:
```
./start-bootstrap.sh
```

* Running a validator from the same node as bootstrap
```
./start-validator.sh 1
```

This will create a directory `validator_1` and create necessary files and ledger to run the validator.
You can run more validator by changing 1 to other integers.

* Running a validator on an external node
```
./start-validator.sh 1 BOOTSTRAP_VALIDATOR_IP_ADDRESS
```


* Staking a validator 1 with 1000 SOLs
```
export validator1=$(solana address -k validator_1/vote.json)
./stake-a-validator $validator1 1000
```