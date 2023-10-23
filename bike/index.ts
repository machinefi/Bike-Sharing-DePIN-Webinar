import { W3bstreamClient } from "w3bstream-client-js";

const URL = "COPY/PASTE FROM WS STUDIO PROJECT EVENTS TAB";
const API_KEY = "CREATE ONE IN WS STUDIO ACCOUNT SETTINGS";

const client = new W3bstreamClient(URL, API_KEY);

const header = {
  device_id: "bike_001",
  event_type: "RIDE_COMPLETED",
};

// Set your wallet address as the bike owner
const payload = {
  data: `{
        "bike_owner": "0x2C37a2cBcFacCdD0625b4E3151d6260149eE866B",
        "ride_start": "${Date.now()}",
        "ride_duration": 3620,
        "ride_distance": 1500
        }`,
};

main();

async function main() {
  try {
    const res = await client.publishSingle(header, Buffer.from(payload.data));

    console.log("Response:");
    console.log(JSON.stringify(res.data, null, 2));
  } catch (error) {
    console.error(error);
  }
}
