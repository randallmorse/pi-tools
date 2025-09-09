for drive in $(lsblk -nd --output NAME,TYPE | awk '$2=="disk"{print $1}'); do 
    dev="/dev/$drive"
    mountpoint=$(lsblk -no MOUNTPOINT "$dev" | head -n 1)
    echo "=== Testing $dev ($mountpoint) ==="
    sudo hdparm -Tt "$dev" | grep "Timing buffered disk reads"
    if [ -n "$mountpoint" ]; then
        testdir="$mountpoint"
        echo "Write test on $testdir"
        sync && dd if=/dev/zero of="$testdir/testfile" bs=1M count=512 conv=fdatasync status=none && rm "$testdir/testfile"
    else
        echo "Not mounted, skipping write test."
    fi
    echo
done
