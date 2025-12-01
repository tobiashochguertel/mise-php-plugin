# mise-php-plugin

A mise tool plugin for PHP that downloads prebuilt binaries instead of compiling from source.

## Features

- **Fast installation** - Downloads prebuilt binaries, no compilation needed
- **Cross-platform** - Supports Linux (x64, arm64) and macOS (Intel, Apple Silicon)
- **Full extensions** - Includes common extensions: curl, openssl, mysqli, pdo_mysql, pgsql, opcache, mbstring, zip, and more
- **Legacy file support** - Reads `.php-version` and `.phpenv-version` files

## Installation

```bash
# Install the plugin
mise plugin install php /path/to/mise-php-plugin

# Or from GitHub (once published)
mise plugin install php https://github.com/tobiashochguertel/mise-php
```

## Usage

```bash
# List available versions
mise ls-remote php

# Install a specific version
mise install php@8.4.6

# Use a version globally
mise use -g php@8.4.6

# Use a version in current directory
mise use php@8.4.6

# Verify installation
php -v
php -m  # List loaded modules
```

## Version Files

The plugin supports legacy version files:

```bash
# .php-version
8.4.6

# Or with prefix
php-8.4.6
```

## Binary Source

This plugin downloads prebuilt PHP binaries from [TorstenDittmann/php-binaries](https://github.com/TorstenDittmann/php-binaries).

### Included Extensions

The prebuilt binaries include these extensions:

**Web & Protocol:**
- curl, openssl, sockets, soap, pcntl, fpm

**Database:**
- mysqli, pdo_mysql, pgsql, pdo_pgsql, sqlite3

**Core & Performance:**
- opcache, bcmath, zip

**Text Processing:**
- mbstring, iconv

## Limitations

- **Windows not supported** - Use official PHP binaries from [windows.php.net](https://windows.php.net)
- **Version availability** - Only versions built by TorstenDittmann are available. Check [releases](https://github.com/TorstenDittmann/php-binaries/releases) for available versions.
- **New PHP versions** - Newly released PHP versions (like 8.5) may not be immediately available until TorstenDittmann builds them.

## Troubleshooting

### Version not found

If a version is not available:
1. Check [TorstenDittmann/php-binaries releases](https://github.com/TorstenDittmann/php-binaries/releases)
2. Consider requesting the version or building locally

### Missing extensions

The prebuilt binaries include common extensions. If you need additional extensions:
1. Use `pecl` to install additional extensions
2. Or build PHP from source using the vfox or asdf backend

## Contributing

1. Fork this repository
2. Make your changes
3. Test with `mise plugin install php ./`
4. Submit a pull request

## License

MIT License

## Credits

- [TorstenDittmann/php-binaries](https://github.com/TorstenDittmann/php-binaries) - Prebuilt PHP binaries
- [mise](https://mise.jdx.dev) - The polyglot tool version manager
