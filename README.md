There are some tools for analysis java application performance.

It's based on linux kernel tool `perf`, so it's performance is much better than any other tools.

And it can trace calls not only inside jvm but the whole system.

`jstack_analyse.sh` is a simple version based on jstack. it's performance is not so well but not require `perf` command.
