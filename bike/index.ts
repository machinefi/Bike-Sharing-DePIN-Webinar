import { W3bstreamClient } from "w3bstream-client-js";

const URL = "https://devnet-prod.w3bstream.com/api/w3bapp/event/eth_0x2c37a2cbcfaccdd0625b4e3151d6260149ee866b_bike_sharing";
const API_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJQYXlsb2FkIjoiNjc3OTE5NDU0ODI3NDE4MCIsImlzcyI6InczYnN0cmVhbSJ9.ssPVNClndpg7SUJYmy8PwkGZyYsOKRWtUIONLWvoa4s";

const client = new W3bstreamClient(URL, API_KEY);

const header = {
  deviceId: "bike_0012",
  eventType: "NEW_RIDE",
};

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
    const res = await client.publish(header, Buffer.from(payload.data));

    console.log("Response:");
    console.log(JSON.stringify(res.data, null, 2));
  } catch (error) {
    console.error(error);
  }
}
