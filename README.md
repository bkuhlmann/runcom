<p align="center">
  <img src="runcom.png" alt="Runcom Icon"/>
</p>

# Runcom

[![Gem Version](https://badge.fury.io/rb/runcom.svg)](http://badge.fury.io/rb/runcom)
[![Circle CI Status](https://circleci.com/gh/bkuhlmann/runcom.svg?style=svg)](https://circleci.com/gh/bkuhlmann/runcom)

Runcom (short for [Run Command](https://en.wikipedia.org/wiki/Run_commands)) provides common
functionality for Command Line Interfaces (CLIs) in which to manage global, local, or multiple
caches, configurations, or data in general. It does this by leveraging the [XDG Base Directory
Specification](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html) built atop
the [XDG](https://github.com/bkuhlmann/xdg) implementation.

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Features](#features)
  - [Requirements](#requirements)
  - [Setup](#setup)
    - [Production](#production)
    - [Development](#development)
  - [Usage](#usage)
      - [Overview](#overview)
      - [Variable Priority](#variable-priority)
      - [Configuration Specialization](#configuration-specialization)
    - [Examples](#examples)
  - [Tests](#tests)
  - [Versioning](#versioning)
  - [Code of Conduct](#code-of-conduct)
  - [Contributions](#contributions)
  - [License](#license)
  - [History](#history)
  - [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

## Features

- Wraps the [XDG](https://github.com/bkuhlmann/xdg) implementation which provides access to the
  following environment variables:
  - `$XDG_CACHE_HOME`
  - `$XDG_CONFIG_HOME`
  - `$XDG_CONFIG_DIRS`
  - `$XDG_DATA_HOME`
  - `$XDG_DATA_DIRS`
- Enhances the XDG cache, config, and data implementation. For the config, the following is
  supported:
  - Supports loading of CLI-specific [YAML](http://yaml.org) configuration file.
  - Supports loading and merging of nested/complex configurations.
  - Supports hash representation of configuration.

## Requirements

1. [Ruby 2.7.x](https://www.ruby-lang.org).

## Setup

### Production

To install, run:

    gem install runcom

Add the following to your Gemfile:

    gem "runcom"

### Development

To contribute, run:

    git clone https://github.com/bkuhlmann/runcom.git
    cd runcom
    bin/setup

You can also use the IRB console for direct access to all objects:

    bin/console

## Usage

The following describes the enhancements built atop the [XDG](https://github.com/bkuhlmann/xdg)
implementation.

#### Overview

While there isn't an environment convenience object as found in the `XDG` namespace, you can
instantiate each object individually:

    cache = Runcom::Cache.new "example/data.json"
    config = Runcom::Config.new "example/configuration.yml"
    data = Runcom::Data.new "example/store.dat"

Each of the above objects share the same API:

- `#relative` - Answers the relative path from which the object was constructed.
- `#namespace` - Answers the relative namespace as a pathname object from which the object was
  constructed. The namespace must be identical across the cache, config, and data objects as this is
  what uniquely identifies and organizes all files associated with your program.
- `#file_name` - Answers the file name from which the object was constructed.
- `#current` - Answers first *existing* file system path computed by `$XDG_*_HOME` followed by each
  computed `$XDG_*_DIRS` path in order defined. Otherwise, `nil` is answered back.
- `#all` - Answers all file system paths which is the combined `$XDG_*_HOME` and `$XDG_*_DIRS`
  values in order defined. These paths *may* or *may not* exist on the file system.
- `#inspect` - Answers a string representation of default XDG home and directory paths for debugging
  purposes.

Using the `cache` object (created above) as an example, here is what each method answers back:

    cache.relative # => #<Pathname:example/data.json>
    cache.namespace # #<Pathname:example>
    cache.file_name # #<Pathname:data.json>
    cache.current # #<Pathname:/Users/bkuhlmann/.cache/example/data.json>
    cache.all # [#<Pathname:/Users/bkuhlmann/.cache/example/data.json>]
    cache.inspect # "XDG_CACHE_HOME=/Users/bkuhlmann/.cache"

#### Variable Priority

Path precedence is determined in the following order (with the first taking highest priority):

1. **Local Configuration** - If a `$XDG_*_HOME` or `$XDG_*_DIRS` path relative to the current
   working directory is detected, it will take precedence over the global configuration. This is the
   same behavior as found in Git where the local `.git/config` takes precedence over the global
   `~/.gitconfig`.
1. **Global Configuration** - When a local configuration isn't found, the global configuration is
   used as defined by the *XDG Base Directory Specification*.

#### Configuration Specialization

The `Runcom::Config` deserves additional highlighting as it provides support for loading custom CLI
configurations directly from the command line or from custom locations. It is meant to be used
within your program(s).

An object is initialized as follows:

    configuration = Runcom::Config.new "example/configuration.yml"

Default settings can be initialized as well:

    configuration = Runcom::Config.new "example/configuration.yml", defaults: {name: "Example"}

Once a configuration has been initialized, a hash representation can be obtained:

    configuration.to_h

A configuration can be merged with another hash (handy for runtime overrides):

    updated_configuration = configuration.merge {name: "Updated Name"}

A configuration can also be merged with another configuration:

    updated_configuration = configuration.merge Runcom::Config.new("other", defaults: {a: 1})

The current path of the configuration can be asked for as well:

    configuration.current # "~/.config/example/configuration.yml"

For further details, study the public interface as provided by the
[`Runcom::Config`](lib/runcom/config.rb) object.

### Examples

Examples of gems built atop this gem are:

- [Gemsmith](https://github.com/bkuhlmann/gemsmith) - A command line interface for smithing new Ruby
  gems.
- [Git Cop](https://github.com/bkuhlmann/git-cop) - Enforces consistent Git commits.
- [Milestoner](https://github.com/bkuhlmann/milestoner) - A command line interface for releasing Git
  repository milestones.
- [Pennyworth](https://github.com/bkuhlmann/pennyworth) - A command line interface that enhances and
  extends [Alfred](https://www.alfredapp.com) with Ruby support.
- [Pragmater](https://github.com/bkuhlmann/pragmater) - A command line interface for
  managing/formatting source file pragma comments.
- [Sublime Text Kit](https://github.com/bkuhlmann/sublime_text_kit) - A command line interface for
  managing Sublime Text metadata.
- [Tocer](https://github.com/bkuhlmann/tocer) - A command line interface for generating table of
  contents for Markdown files.

## Tests

To test, run:

    bundle exec rake

## Versioning

Read [Semantic Versioning](https://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

## Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

## Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

## License

Copyright 2016 [Alchemists](https://www.alchemists.io).
Read [LICENSE](LICENSE.md) for details.

## History

Read [CHANGES](CHANGES.md) for details.
Built with [Gemsmith](https://github.com/bkuhlmann/gemsmith).

## Credits

Developed by [Brooke Kuhlmann](https://www.alchemists.io) at
[Alchemists](https://www.alchemists.io).
