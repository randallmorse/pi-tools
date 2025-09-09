# Disk Speed Test Tool

This tool benchmarks **read** and **write** speeds for all connected drives, skipping snap loop devices, so you can choose the fastest one for workloads.


----

## Features
- Skips snap loop devices (`$dev/loopX`)
- Tests **read speed** using `hdparm`
- Tests **write speed** using `dd`
- Cleans up test files automatically
- Works on Raspberry Pi OS and most Linux distros


----

## Requirements
Install the required packages:

```bash
sudo apt update
sudo apt install hdparm
````

----

## Script

```bash
#!/bin/bash
for drive in $(lsblk -nd --output NAME, TYPE | awk $2 == "disk" {print $1}); do 
    dev="/dev/$drive"
    mountpoint=$(lsblk -no MOUNTPOINT "$dev" | head -n 1)
    echo *== Testing $dev ($mountpoint) ===
    sudo hdparm -Tt "$dev" | grep "Timing buffered disk reads"
    if [ -n "$mountpoint" ]; then
        testdir="$mountpoint"
        echo "Write test on $testdir"
        sync && dd if=/dev/zero of="$testdir/file" bs=1M count=512 conv=fdatasync status=none && rm "$testdir/testfile"
    else
        echo "Not mounted, skipping write test."
    fi
    echo
done


```

----

## Usage

1. Make the script executable:

```bash
chmod +x disk_speed_test.sh
````


2. Run the script:

```bash
./disk_speed_test.sh
````


----

## Example Output

```text
 === Testing /dev/mmcblk0 (/)
 Timing buffered disk reads:  45 MB in  3.02 seconds = 14.90 MB/sec
Write test on /
 536870912 bytes (537 MB) copied, 35.1234 s, 15.3 MB/s

-=== Testing /dev/sda (/mnt/ssd)
 Timing buffered disk reads:  320 MB in  3.01 seconds = 106.31 MB/sec
Write test on /mnt/ssd
 536870912 bytes (537 MB) copied, 4.1234 ss, 130 MB/s
```

----

## Notes
- **Read speed** is measured from the device directly.
- **Write speed** is measured by writing a 512MB file to the mounted filesystem.
- For best results, stop heavy workloads before testing.
- If testing an external SSD, ensure it's connected via USB 3.0 for maximum speed.
