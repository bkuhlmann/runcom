# Runcom

[![Gem Version](https://badge.fury.io/rb/runcom.svg)](http://badge.fury.io/rb/runcom)
[![Code Climate Maintainability](https://api.codeclimate.com/v1/badges/129b7ea524a0f5a6a805/maintainability)](https://codeclimate.com/github/bkuhlmann/runcom/maintainability)
[![Code Climate Test Coverage](https://api.codeclimate.com/v1/badges/129b7ea524a0f5a6a805/test_coverage)](https://codeclimate.com/github/bkuhlmann/runcom/test_coverage)
[![Gemnasium Status](https://gemnasium.com/bkuhlmann/runcom.svg)](https://gemnasium.com/bkuhlmann/runcom)
[![Circle CI Status](https://circleci.com/gh/bkuhlmann/runcom.svg?style=svg)](https://circleci.com/gh/bkuhlmann/runcom)
[![Patreon](https://img.shields.io/badge/patreon-donate-brightgreen.svg)](https://www.patreon.com/bkuhlmann)

Runcom (a.k.a. [Run Command](https://en.wikipedia.org/wiki/Run_commands)) provides common
functionality for Command Line Interfaces (CLIs) in which to manage global, local, or multiple
configurations in general. It does this by leveraging the
[XDG Base Directory Specification](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html).
Read on for further details.

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Features](#features)
  - [Requirements](#requirements)
- [Setup](#setup)
  - [Usage](#usage)
    - [`Runcom::Configuration`](#runcomconfiguration)
    - [XDG](#xdg)
      - [`$XDG_CONFIG_DIRS`](#xdg_config_dirs)
      - [`$XDG_CONFIG_HOME`](#xdg_config_home)
      - [Variable Priority](#variable-priority)
  - [Tests](#tests)
  - [Versioning](#versioning)
  - [Code of Conduct](#code-of-conduct)
  - [Contributions](#contributions)
  - [License](#license)
  - [History](#history)
  - [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Features

- Provides run command customization by loading a CLI-specific configuration from a
  [YAML](http://yaml.org) file.
- Automatically detects and resolves resource configuration file path based on XDG environment
  variables which provides several benefits:
  - Uses the `$XDG_CONFIG_HOME` or `$XDG_CONFIG_DIRS` variables to define configuration paths.
  - Improves configuration organization by not littering your `$HOME` directory with `*rc` files and
    keeping them within a central configuration folder.
- Supports loading and merging of nested/complex configurations.
- Supports hash representation of configuration.

## Requirements

0. [Ruby 2.4.x](https://www.ruby-lang.org)

# Setup

Type the following to install:

    gem install runcom

Add the following to your Gemfile:

    gem "runcom"

## Usage

### `Runcom::Configuration`

This object provides support for loading custom CLI configurations directly from the command line or
from custom locations. It is meant to be used within your CLI program(s).

An object can be initialized as follows:

    configuration = Runcom::Configuration.new project_name: "example"

The default file name for a configuration is `configuration.yml` but a custom name can be used if
desired:

    configuration = Runcom::Configuration.new project_name: "example", file_name: "example.yml"

Default settings can be initialized as well:

    configuration = Runcom::Configuration.new project_name: "example", defaults: {name: "Example"}

Once a configuration has been initialized, a hash representation can be obtained:

    configuration.to_h

A configuration can be merged with another hash (handy for runtime overrides)

    updated_configuration = configuration.merge {name: "Updated Name"}

The computed path of the configuration can be asked for as well:

    configuration.path # "~/.config/example/configuration.yml"

For further details, study the public interface as provided by the
[`Runcom::Configuration`](lib/runcom/configuration.rb) object.

### XDG

This gem leverages the XDG `$XDG_CONFIG_DIRS` and `$XDG_CONFIG_HOME` environment variables which are
used to compute the configuration path (as mentioned above). The following details how to take
advantage of the XDG variables (additional details can be found by reading the
[XDG Specification](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html)).

#### `$XDG_CONFIG_DIRS`

This variable is used to define a colon delimited list of configuration directories. The order is
important as the first directory defined will take precedent over the following directory and so
forth. Example:

    XDG_CONFIG_DIRS="/example/one/.config:/example/two/.settings:/example/three/.configuration"

    # Yields the following array:
    [
      "/example/one/.config",
      "/example/two/.settings",
      "/example/three/.configuration"
    ]

In the above example, the `"/example/one/.config"` path will take highest priority since it was
defined first.

When the `$XDG_CONFIG_DIRS` is not defined, it will default to the following array: `["/etc/xdg"]`.

#### `$XDG_CONFIG_HOME`

This is the environment variable you'll want to use the most as it takes precidence over
`$XDG_CONFIG_DIRS` environment variable. It is not required to be defined as it defaults to
`$HOME/.config` which is generally want you want.

#### Variable Priority

Configuration path precedence is determined in the following order (with the first taking highest
priority):

0. `$XDG_CONFIG_HOME` - Will be used if defined *and* exists on the local file system. Otherwise,
   falls back to the `$XDG_CONFIG_DIRS` array.
0. `$XDG_CONFIG_DIRS` - Iterates through defined directories starting with the first one defined
   (highest priority). It will choose the first directory, in priority, that exists on the file
   system while skipping any that don't exist.

## Tests

To test, run:

    bundle exec rake

## Versioning

Read [Semantic Versioning](http://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

## Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

## Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

Copyright (c) 2016 [Alchemists](https://www.alchemists.io).
Read [LICENSE](LICENSE.md) for details.

## History

Read [CHANGES](CHANGES.md) for details.
Built with [Gemsmith](https://github.com/bkuhlmann/gemsmith).

## Credits

Developed by [Brooke Kuhlmann](https://www.alchemists.io) at
[Alchemists](https://www.alchemists.io).
