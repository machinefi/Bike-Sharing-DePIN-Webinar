// Copyright 2023 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#![no_main]
// #![no_std]

use risc0_zkvm::guest::env;

risc0_zkvm::guest::entry!(main);

pub fn main() {
    // Load the ride data (ride_time, ride_distance) from the host
    let ride_data: String = env::read();
    // Load the ride_id from the host
    let ride_id_str: String = env::read();

    let ride_id: u64 = ride_id_str.parse().expect("Invalid ride id");

    let mut ride_time: u64 = 0;
    let mut ride_distance: u64 = 0;
    
    // Parse the ride data to split and cast ride_time and ride_distance
    let split: Result<Vec<u64>, _> = ride_data.split(",").map(|s| s.trim().parse::<u64>()).collect();
    match split {
        Ok(v) => (ride_time, ride_distance) = (v[0], v[1]),
        Err(e) => {
            env::log(&format!("Private input parse error, format: ride_time,ride_distance. Error: {:?}", e));
        }
    };

    let ride_cost: u64 = ride_time + ride_distance * 2;

    let s = format!(
        "I know this ride_id {} iscompleted and cost is {}, and I can prove it!",
        ride_id, ride_cost
    );

    env::log(&s);
    
    env::commit(&ride_cost.to_be_bytes());
    env::commit(&ride_id.to_be_bytes());

}



