# Episode #2

In part 1, the bike owner's address was embedded into the bike data message. While this method could be easily implemented through ownership settings in the bike-sharing mobile app, such as through Bluetooth, it has limitations. For example, it restricts Web3 composability, and the owner must have physical access to the bike to change ownership.

In part 2, we aim to manage bike owners in a more flexible manner by recording ownership information in a blockchain contract. Each manufactured bike will be registered on the blockchain in a dedicated device registry contract. The best way to achieve this is to implement an NFT token contract to "mint" any new manufactured bike. The simple existance of an NFT for a certain Bike Id means that bike is part of our ecosystem, while the ownership of the NFT is simply the owner of the bike. This provides lots of flexibility to our project as well as composability: in fact, bike owners can check their bikes in a Metamask wallet, they can easily transfer ownership, or even sell their bikes in any NFT marketplace.

Consequently, every time a bike sends data to our W3bstream prover, it will have to include its unique device ID to "identify" itself as one of our bikes. Ideally, the data message should also be signed but for the sake of simplicity we will skip this here. The applet will retrieve the current bike's owner information from the NFT contract on chain to determine where to send the payments for that bike. 

Let's outline the changes to the project below:

1. Each bike should be assigned a unique ID, which we will generate as a public/private key pair, using the public key as the bike's unique identifier (and, ideally, the private key should be used by the bike to sign messages).
2. We will create a "Bikes" NFT contract where the project owner will mint each manufactured bike, with the token id being the actual bike id (i.e. the public key mentioned above).
3. We will modify the W3bstream Applet to retrieve the owner for a particular bike from the bikes NFT contract to determine the correct recipient of the payment upon completing a ride.
6. Finally, we will modify the bike simulator to remove the owner address from the message and include the bike_id instead.

## Step 1: Create the Bikes NFT Contract
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This is an ERC721 contract that keeps track of the bikes registered in our ecosystem

// Import ERC721 from Openzeppelin
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// Import Ownable
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bikes is ERC721, Ownable {

    constructor() ERC721("Bikes", "BIKES") { }

    // Override tokenURI to return the tokenURI of the tokens
    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        return "ipfs://QmNe6Hv4rZf1JxDtwHzHWbE2ders9qpnR3tRFddxVs4BJ4";
    }

    // Function to mint a new token
    function mint(address to, uint256 tokenId) public onlyOwner {
        _mint(to, tokenId);
    }
}
```

- Add the deploy script
```js
module.exports = async ({ getNamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  const tx = await deploy("Bikes", {
    from: deployer,
    args: [],
    log: true,
  });

  console.log("Bikes NFT deployed at block: ", tx.receipt.blockNumber);
};
module.exports.tags = ["Token"];
```

- Add a mint bike hardhat task and include it into index.js (clone add-minter-role)
```js
const { NumberIncrementStepper } = require("@chakra-ui/react");

task("mint-bike", "Mints a new bike to the buyer")
  .addParam("owneraddress", "The owner of the bike")
  .addParam("bikeid", "Public key of the bike, must be decimal")
  .setAction(async (taskArgs, hre) => {
    const { bikeid, owneraddress } = taskArgs;
    const { deployments } = hre;
    const [deployer] = await ethers.getSigners();

    const Bikes = await deployments.get("Bikes");
    const bikes = await ethers.getContractAt("Bikes", Bikes.address, deployer);

    const tx = await bikes.mint(owneraddress, parseInt(bikeid));
    await tx.wait();

    console.log(`Minter role granted to ${owneraddress}`);
  });
```
- Mint a first bike to yourself

```
npx hardhat mint-bike --owneraddress 0x4c123380CA640a146D803f844E0D9c90b52C5C97 --bikeid 15832596125535338599405207978761684130990195597857335228524521905597089730101 --network testnet
```

Edit the WS Applet:

```
// ERC20.ts
import { GetDataByRID, Log, SendTx, CallContract } from "@w3bstream/wasm-sdk";

import { buildTxData } from "../utils/build-tx";
import { getIntegerField, getPayloadValue, getStringField } from "../utils/payload-parser";

// Set the token contract address. This is the address of the dapp's token, 
// which is used for paying rides and rewarding bike owners
const TOKEN_CONTRACT_ADDRESS = "TOKEN CONTRACT ADDRESS";
const BIKES_CONTRACT = "BIKES NFT CONTRACT ADDRESS";

const MINT_FUNCTION_ADDR = "40c10f19";
const CHAIN_ID = 4690;
const WEIGHT_DISTANCE = 0.001; // Pay 1 token every 1km
const WEIGHT_DURATION = 0.005; // Pay 1 token every 3 minutes

// This global variable counts each line logged to the console
let lineCount: i32 = 0;

/*
* Each time a new ride is completed, the device sends a message 
* to the W3bstream applet that looks like this:
* {
*   "bike_owner": "0xabcd...",
*   "ride_start": "123456789",
*   "ride_duration": 12345,
*   "ride_distance": 12345,
*/

export function handle_data(rid: i32): i32 {
  log("New ride data received!");
  const deviceMessage = GetDataByRID(rid);
  log("Payload: " + deviceMessage);
  
  const payload = getPayloadValue(deviceMessage);

  const bike_id = getStringField(payload, "bike_id");
  const ride_start = getStringField(payload, "ride_start");
  const ride_duration = getIntegerField(payload, "ride_duration");
  const ride_distance = getIntegerField(payload, "ride_distance");

  if (
    bike_id === null || 
    ride_start === null || 
    ride_duration === null || 
    ride_distance === null) {
    log("Invalid payload, fields cannot be null");
    return 1;
  }

  log("Bike id: " + bike_id);
  log("Ride start: " + ride_start);
  log("Ride duration: " + ride_duration.toString() + " seconds")
  log("Ride distance: " + ride_distance.toString() + " meters");


  const due: f64 = 
    f64(ride_duration) * WEIGHT_DURATION + 
    f64(ride_distance) * WEIGHT_DISTANCE;
  
  log("Due amount: " + due.toString());
  log("Sending tokens to owner address...");
  log("Token Contarct: " + TOKEN_CONTRACT_ADDRESS);

  let bike_owner = getBikeOwner(bike_id);

  mintRewards(bike_owner, due.toString());

  return 0;
}

// Reads the bike owner address from the blockchain
function getBikeOwner(bikeId: string): string {
  log("Getting bike owner...");
  let owner = CallContract(4690, BIKES_CONTRACT, "6352211e" + bikeId, );
  // Take the last 40 characters of the result
  owner = owner.slice(owner.length - 40, owner.length);
  log("Owner: 0x" + owner);
  return owner;
}


function mintRewards(ownerAddress: string, amount: string): void {
  log(`Minting ${amount} tokens to ${ownerAddress}`);
  const txData = buildTxData(MINT_FUNCTION_ADDR, ownerAddress, amount);
  const res = SendTx(CHAIN_ID, TOKEN_CONTRACT_ADDRESS, "0", txData);
  log("Send tx result:" + res);
}

export function log(str: string): void {
  // logs the line count and the message
  Log(lineCount.toString() + ". " + str);
  lineCount += 1;
}
```

Edit the bike simulator

```js
import { W3bstreamClient } from "w3bstream-client-js";

const URL = "https://devnet-prod-api.w3bstream.com/event/eth_0x4c123380ca640a146d803f844e0d9c90b52c5c97_bike_sharing";
const API_KEY = "w3b_MV8xNjk4MjMyNzQ5X28uIWVXTUxTKz0zLw";

const client = new W3bstreamClient(URL, API_KEY);

const header = {
  device_id: "bike_001",
  event_type: "RIDE_COMPLETED",
};

// Set your wallet address as the bike owner
const payload = {
  data: `{
        "bike_id": "0x2300ee8d4d4661138be2c7a3a0497086fcdd2aba94f5b9dcfb9169f497024e35",
        "ride_start": "${Date.now()}",
        "ride_duration": 3620,
        "ride_distance": 1500
        }`,
};
```


