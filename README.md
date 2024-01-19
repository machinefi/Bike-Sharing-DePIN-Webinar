# Episode #4
In this 4th episode of the series, we have crafted a special example to explore generating ZK proofs using W3bstream, and deploying them on the Linea blockchain as the dApp layer where the DePIN contracts are housed.

This episode is a 'Linea Special' and is divided into two parts. In this first part, we describe the demo and implement the smart contracts on the Linea Goerli Testnet. The second part will focus on implementing the prover on the IoTeX W3bstream layer and integrating everything.

Stay tuned for the next part!

## Part 1: deploy contracts on Linea

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
