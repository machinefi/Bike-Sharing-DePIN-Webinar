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

```
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

- Create a `bike_sharing` project on devnet.w3bstream.com
- Import applet/release.wasm
- In the Project Settings tab, copy the operator address

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
- edit index.ts, set the API Key
- In your W3bstream Project Events page, copy the HTTP route
- edit index.ts, set the route

```bash
tsc && node dist/index.js
```

- Check the Log section on WS Studio
- Check the token balance in Metamask
