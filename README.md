# oneaws-flake

A Nix flake for the [oneaws](https://github.com/k1LoW/oneaws) Ruby gem.

## Features

- Development environment with Ruby 3.3, Bundler, and AWS CLI
- Direct installation of oneaws via `nix profile install`
- Isolated gem dependencies without conflicts

## Installation

### Using nix profile

```bash
nix profile install github:tnmt/oneaws-flake
```

Or with priority to avoid conflicts:

```bash
nix profile install github:tnmt/oneaws-flake --priority 4
```

### Using nix run

```bash
nix run github:tnmt/oneaws-flake -- version
```

## Development

Enter the development shell:

```bash
nix develop
```

This provides:
- Ruby 3.3
- Bundler
- Git
- AWS CLI v2

## Build

Build the package locally:

```bash
nix build
./result/bin/oneaws version
```

## Usage

After installation, use oneaws to get AWS credentials from OneLogin:

```bash
oneaws getkey
```

See the [oneaws documentation](https://github.com/k1LoW/oneaws) for more details on configuration and usage.