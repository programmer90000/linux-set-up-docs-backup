# Diff

| Command                          | Purpose         |
|----------------------------------|-----------------|
| wdiff FILE-1 FILE-2 \| colordiff | Compare 2 files |

| Flag                  | Purpose                                                       |
|-----------------------|---------------------------------------------------------------|
| --no-deleted          | Don't show deleted lines from the 2 files                     |
| --no-inserted         | Don't show inserted lines from the 2 files                    |
| --no-common           | Don't show lines which are the same from the 2 files          |
| --statistics          | Show statistics at the end of the file about what has changed |
| --avoid-wraps         | Stop lines in the output from wrapping                        |
| --start-delete=STRING | String to display at the beginning of a deletion              |
| --end-delete=STRING   | String to display at the end of a deletion                    |
| --start-insert=STRING | String to display at the beginning of an insertion            |
| --end-insert=STRING   | String to display at the end of an insertion                  |
| --ignore-case         | Ignore case                                                   |
| --diff-input          | Read a diff file instead of comparing 2 files                 |
