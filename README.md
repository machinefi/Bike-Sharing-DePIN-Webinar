# Episode #1

```bash
git clone https://github.com/simonerom/bike-sharing && cd bike-sharing
cd blockchain
npm install
echo IOTEX_PRIVATE_KEY=0x... > .env
npx hardhat deploy --network testnet
```

- Copy the token contract address and import it into Metamask to be able to check the balance
- Edit `../applet/assembly/handlers/erc20.ts` and set the token contract address 

```js
// erc20.ts
...
const TOKEN_CONTRACT_ADDRESS = "0x12345...ABC";
...
```
  
```
cd ../applet
npm install
npm run asbuild
```

- Create a `bike_sharing` project on devnet.w3bstream.com and import `applet/release.wasm`
- In the Project Settings tab, copy the operator address (here you can also update the WASM file if you make changes to the applet)

```bash
cd ../blockchain
npx hardhat add-erc20-minter --address <YOUR_OPERATOR_ADDRESS>  --network testnet
```

- Fund the Project operator address with some test IOTX tokens (get some from your IoTeX Developer Dashboard on https://developers.iotex.io)

```bash
cd ../bike
npm install
```
- In your W3bstream account settings, create an API Key and call it `bike_company`, make sure it has read/write permissions for the **Event** item and copy the Key
- Edit `index.ts`, set the API Key
- In your W3bstream Project Events page, copy the HTTP route
- Edit `index.ts` again, set the route and set your wallet address as the bike owner in the message payload:

```js
...
// Set your wallet address as the bike owner address
const payload = {
  data: `{
        "bike_owner": "0x2C37a2cBcFacCdD0625b4E3151d6260149eE866B",
        "ride_start": "${Date.now()}",
        "ride_duration": 3620,
        "ride_distance": 1500
        }`,
...
```

```bash
tsc && node dist/index.js
```

- Check the Log section on WS Studio
- Check the token balance in Metamask
