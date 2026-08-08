# Take a snapshot

Run:
```
virsh snapshot-create-as --domain YourVMName --name "SnapshotName" --description "Snapshot Description"
```

# List all snapshots

Run:
```
virsh snapshot-list YourVMName
```

# Revert to a snapshot

Run:
```
virsh snapshot-revert --domain YourVMName --snapshotname "SnapshotName"
```

# Delete a snapshot

Run:
```
virsh snapshot-delete --domain YourVMName --snapshotname "SnapshotName"
```
