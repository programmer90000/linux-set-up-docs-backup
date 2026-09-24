# Check If A Command Is Frozen

How to check if a command is frozen:

Run:
```
ps aux | grep "COMMAND I RAN"
```

Find the PID of the command I ran

> Note: If the command contains no spaces, I don't need the speech marks

> If I typed a long command, ps might truncate or wrap it. In that case, a long grep pattern won't match. Use a shorter, distinctive substring instead

Run:
```
sudo strace -p <PID>
```

If the command is running, you will see a stream of lines scrolling by

> Note: The lines may be similar or even the same. However, new lines will continue logging to the terminal

If the commad is frozen, the output will stop on one line. Look at that line.

If it looks like `futex(0x..., FUTEX_WAIT, ...` and has `no = 0` at the end, it is blocked waiting on a lock (often a thread synchronization issue)

If it ends in `... <unfinished ...>`, it is stuck inside that specific system call, likely waiting for I/O (like a network mount)

Press Ctrl+C to detach strace once done, the main command will continue running

If strace shows the command is busy but taking a long time, switch to summary mode to see what it is doing

Run this command for about 10 seconds:
```bash
sudo strace -c -p <PID>
```

Press Ctrl+C to stop

You will see a table. Look at the errors column first. A high number of errors (e.g., 8,000 failing stat calls) usually indicates a bug or a permission loop. Then look at % time to see the slowest system call
