# DocPipeline

Example pipeline for typesetting and building `markdown` documentation via `ConTeXt` and `pandoc`.

Slightly simplified version of [Dave Jarvis' guide](https://dave.autonoma.ca/blog/2019/05/22/typesetting-markdown-part-1/).

```shell
$ docs/build.sh -d
[20:08:18.4N] Check missing software requirements
[20:08:18.4N] Execute tasks
[20:08:18.4N] Concatenate files to body.md
[20:08:18.4N] Generate body.tex
[20:08:18.4N] Generate body.pdf
[20:08:21.4N] Rename body.pdf to output.pdf
```

or use docker containers to skip installing `ConTeXt` and `pandoc`:

```shell
$ docs/build.sh -d -c
[20:08:55.4N] Check missing software requirements
[20:08:55.4N] Execute tasks
[20:08:55.4N] Concatenate files to body.md
[20:08:55.4N] Generate body.tex via Docker Container
[20:08:57.4N] Generate body.pdf via Docker Container
[20:08:03.4N] Rename body.pdf to output.pdf
```
