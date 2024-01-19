# Episode #4

In this 4th episode of the series, we created a special example to experiment with generating ZK proofs from w3bstream and using the Linea blockchain as the dApp layer where the DePIN contarcts are deployed.

This is a "Linea special episode" and is split into two parts: in this first part we describe the demo and implement the smart contracts on the Linea Goerli Testnet. In the second part we will implement the prover on the IoTeX W3bstrea layer and put everything together.

## Part 1: deploy contracts

### Setup

```sh
# Export your Linea Devnet Private key (make sure it's funded with some test tokens)
export PRIVATE_KEY=abc123...def456
```

### Deploy

```sh
npm install
npx run deploy:testnet
```

## Part 2: Deploy the W3bstream prover

TODO

## Part 3: Test the project

## Request a new ride

```sh
npx hardhat startRide --bikeid 0x1 --depositamount 1000000000000000000 --network testnet
```

## Complete the ride

We will use the `ioctl` command line client to send an "EndRide message" from an hipotetycal bike.

TODO