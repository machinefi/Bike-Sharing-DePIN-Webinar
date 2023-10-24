import { W3bstreamClient } from "w3bstream-client-js";

const URL = "W3BSTREAM PROJECT HTTP ROUTE";
const API_KEY = "W3BSTREAM ACCOUNT API KEY";

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

main();

async function main() {
  try {
    /*
     * We should sign the data field of the payload with the private key of the bike. 
    */
    const res = await client.publishSingle(header, Buffer.from(payload.data));

    console.log("Response:");
    console.log(JSON.stringify(res.data, null, 2));
  } catch (error) {
    console.error(error);
  }
}
