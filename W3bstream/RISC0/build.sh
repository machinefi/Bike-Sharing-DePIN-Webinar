cargo build --release
ioctl-unstable ws code convert -t "risc0" -v "0.1" -i "/Users/simone/Source/GitHub/machinefi/sprout/examples/bikesharing/target/release/build/range-method-47f94bc767a942c9/out/methods.rs" -o 30000.json -e "{\"image_id\":\"RANGE_ID\", \"elf\":\"RANGE_ELF\"}"
mv risc0-config.json ../../test/project/30000