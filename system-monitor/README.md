Notes:

This app was made by AI. I have tested it on Termux on my phone. It works on there. I don't know if the information is accurate or not

I still need to add all of the other information to the app

To run:
```
cargo build --release
./target/release/sysmon-tui
sudo ./target/release/sysmon-tui --interval 500 --sqlite-log my_metrics.db
./target/release/sysmon-tui --filter "systemd" --sort-by mem
```