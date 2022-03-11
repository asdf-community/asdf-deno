# asdf-deno

[Deno](https://deno.land) plugin for asdf version manager

## Build History

[![Build history](https://buildstats.info/github/chart/asdf-community/asdf-deno?branch=master)](https://github.com/asdf-community/asdf-deno/actions)

## Prerequirements

- Make sure you have the required dependencies installed:
  - curl
  - git
  - gunzip (for v0.35.0 or lower)
  - unzip (for v0.36.0 or higher)
- To build from source, you will need these dependencies:
  - cargo (you can install it through [asdf-rust](https://github.com/asdf-community/asdf-rust))

## Installation

```bash
asdf plugin-add deno https://github.com/asdf-community/asdf-deno.git
```

## Usage

Check [asdf](https://github.com/asdf-vm/asdf) readme for instructions on how to
install & manage versions.

### Install from source

Rust's cargo is needed in order to install from the source.

#### Install specific version

To install specific version from source, use

```bash
asdf install deno ref:<version>
```

To install the latest version, run `asdf install deno ref:latest`

#### Install specific version by git commit

To install specific version by git commit from source, use

```bash
asdf install deno ref:<full-commit-hash>
```

## License

Licensed under the
[Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
