None selected

Skip to content
Using Gmail with screen readers

5 of 6,023
(no subject)
Inbox

My Old Phone
Sep 22, 2026, 5:11 PM (21 hours ago)
to me

How to check if a command is frozen:

Run:
```
ps aux | grep "COMMAND I RAN"
```

Find the PID of the command I ran

Note: If the command contains no spaces, I don't need the speech marks. If I typed a long command, ps might truncate or wrap it. In that case, a long grep pattern won't match. Use a shorter, distinctive substring instead

Run:
```
sudo strace -p <PID>
```

If it's working: You will see a stream of lines scrolling by (like openat(...), getdents(...)). The process is not frozen, just slow .

If it's frozen: The screen will go silent and stop on one line. Look closely at that line.

If it looks like futex(0x..., FUTEX_WAIT, ... and has no = 0 at the end, it is blocked waiting on a lock (often a thread synchronization issue) .

If it ends in ... <unfinished ...>, it is stuck inside that specific system call, likely waiting for I/O (like a network mount) .

Press Ctrl+C to detach strace when you are done. Your find command will continue running .

If strace shows it is busy but taking forever, switch to summary mode. This shows you where the time is going.

1. Run this command for about 10 seconds :
```bash
sudo strace -c -p <PID>
```
2. Press Ctrl+C to stop.
3. You will see a table. Look at the errors column first. A high number of errors (e.g., 8,000 failing stat calls) usually indicates a bug or a permission loop. Then look at % time to see the slowest system call .
