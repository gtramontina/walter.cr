<h1 align="center">
  <img src="https://img.icons8.com/color/480/000000/walter-white.png" width="120"><br>
  WALTER<br>
  <sup><sub><sup><sub>KEEPING YOUR CRYSTAL CLEAN</sub></sup></sub></sup>
</h1>

<p align="center">
  <a href="https://travis-ci.org/gtramontina/walter.cr" title="Master build status"><img src="https://travis-ci.org/gtramontina/walter.cr.svg?branch=master" alt="Master build status"></a>
</p>

## What <img src="https://png.icons8.com/wired/96/000000/help.png" align="right" width="24">

`walter` is a command line tool that aims to keep your crystal clean, simplifying the routine checks on staged files that are ready to be committed and help you maintain a healthy and clean codebase.

## Why <img src="https://png.icons8.com/wired/96/000000/information.png" align="right" width="24">

From a consistency perspective, there are plenty of tools that support us on our never-ending pursue of code-cleanliness. Linters, static code analyzers, code formatters… Great! However, more often than not, our git history ends up cluttered with [~~angry~~](https://github.com/search?q=fixing+lint+fuck&type=Commits) [commits](https://github.com/search?p=2&q=fixing+lint&type=Commits) fixing violations detected by those tools.

One way to avoid these commits from getting into our history is to run your linters and code formatters _before_ committing your changes. But running these tools against the entire project every time you're committing something can be slow and lead to unexpected or irrelevant results.

This tool allows you to specify a series of commands to run on staged files that match a given pattern.

## Installing <img src="https://png.icons8.com/wired/96/000000/maintenance.png" align="right" width="24">

Add the following entry to your `shard.yml` on the `development_dependencies` section and run `shards install`.

```yaml
walter.cr:
  github: gtramontina/walter.cr
  version: <current-version>
```
<p align="right"><sup><code>shard.yml</code></sup></p>

Next, create a `.walter.yml` at the root of your project with the following content:

```yaml
expression: \.cr$
command:
  - crystal tool format
  - git add
```

<p align="right"><sup><code>.walter.yml</code></sup></p>

Executing `bin/walter` now would run `crystal tool format` and `git add` on your staged files that match the `\.cr$` regular expression. For example, if you have `file1.txt`, `file2.cr` and `file3.cr`, `water` will run, in this order:

1. `crystal tool format file2.cr`
2. `git add file2.cr`
3. `crystal tool format file3.cr`
4. `git add file3.cr`

Notice that `file1.txt` was not referenced, as it doesn't match the `\.cr$` regular expression.

Running the commands on each individual staged file was deliberate. The idea is that it would foster a small/atomic commit mindset.

### More Examples

Here's a few more configuration examples for you to draw inspiration from:

* Run [ameba](https://github.com/veelenga/ameba) linting:

```yaml
expression: \.cr$
command: bin/ameba
```

* Optimize PNG images with [pngcrush](https://pmt.sourceforge.io/pngcrush/):

```yaml
expression: \.png$
command:
  - pngcrush -ow
  - git add
```

* All examples at once:

```yaml
- expression:
    - \.cr$
  command:
    - bin/ameba
    - crystal tool format
    - git add

- expression:
    - \.png$
  command:
    - pngcrush -ow
    - git add
```

### Tips

* Although you can manually run `bin/walter` before every commit, this quickly becomes boring and quite often forgotten. You can leverage the [`precommit`](https://git-scm.com/docs/githooks#_pre_commit) git hook. Take a look at [ghooks.cr](https://github.com/gtramontina/ghooks.cr). It makes versioning your git hooks easier! Here's an example of a ghooks pre-commit hook (`.githooks/pre-commit`) configured to run `bin/walter`:

```sh
#!/usr/bin/env sh
bin/walter
```

<p align="right"><sup><code>.githooks/pre-commit</code></sup></p>

### Help

```
Walter - Keeping your Crystal clean!

Usage:
  walter
  walter (-c <config> | -C <config-file>)
  walter (-h | --help | -v | --version)

Options:
  -h --help                         Show this screen.
  -v --version                      Show version.
  -c --config=<config>              Rules configuration in YAML.
  -C --config-file=<config-file>    Rules configuration file in YAML [default: .walter.yml]
```

<p align="right"><sup><code><b>$</b> bin/walter --help</code></sup></p>

## Design Decisions <img src="https://png.icons8.com/wired/96/000000/idea.png" align="right" width="24">

* Every interaction with the operating system is abstracted;
* Methods have only one output (no exceptions or nils). If needed, use the `Result` class;
* Favor composition over inheritance: augment behavior by decorating existing implementations;

## Contributing <img src="https://png.icons8.com/wired/96/000000/laptop.png" align="right" width="24">

Contributions of any kind are very welcome!

### Developing

At the root of the project, you'll find a `Makefile`. This is meant to be the entry point for any build step during development. Running `make help` will yield you a list of existing phony targets:

```
make build
make clean
make format
make help
make install (default)
make lint
make test
```

<p align="right"><sup><code><b>$</b> make help</code></sup></p>

## References <img src="https://png.icons8.com/wired/96/000000/moleskine.png" align="right" width="24">

* This project is heavily inspired by [@okonet](https://github.com/okonet)'s [🚫💩lint-staged](https://github.com/okonet/lint-staged). Thank you!
* Icons by [Icons8](https://icons8.com).
