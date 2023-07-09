import { handle_data, log } from "./erc20";

export function start(rid: i32): i32 {
  log("----------\n");
  return handle_data(rid);
}
