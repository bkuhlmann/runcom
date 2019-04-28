<p align="center">
  <img src="runcom.png" alt="Runcom Icon"/>
</p>

# Runcom

[![Gem Version](https://badge.fury.io/rb/runcom.svg)](http://badge.fury.io/rb/runcom)
[![Code Climate Maintainability](https://api.codeclimate.com/v1/badges/129b7ea524a0f5a6a805/maintainability)](https://codeclimate.com/github/bkuhlmann/runcom/maintainability)
[![Code Climate Test Coverage](https://api.codeclimate.com/v1/badges/129b7ea524a0f5a6a805/test_coverage)](https://codeclimate.com/github/bkuhlmann/runcom/test_coverage)
[![Circle CI Status](https://circleci.com/gh/bkuhlmann/runcom.svg?style=svg)](https://circleci.com/gh/bkuhlmann/runcom)

Runcom (a.k.a. [Run Command](https://en.wikipedia.org/wiki/Run_commands)) provides common
functionality for Command Line Interfaces (CLIs) in which to manage global, local, or multiple
caches, configurations, or data in general. It does this by leveraging the [XDG Base Directory
Specification](https://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html). Read on for
further details.

<!-- Tocer[start]: Auto-generated, don't remove. -->

## Table of Contents

  - [Features](#features)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Usage](#usage)
    - [XDG](#xdg)
      - [Overview](#overview)
      - [Variable Defaults](#variable-defaults)
      - [Variable Behavior](#variable-behavior)
        - [`$XDG_*_DIRS`](#xdg__dirs)
        - [`$XDG_*_HOME`](#xdg__home)
      - [Variable Priority](#variable-priority)
    - [Runcom](#runcom)
      - [Overview](#overview-1)
      - [Variable Priority](#variable-priority-1)
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

- Provides an embedded `XDG::Environment` implementation that strictly adheres to the *XDG Base
  Directory Specification* which provides access to the following environment settings:
  - `$XDG_CACHE_HOME`
  - `$XDG_CONFIG_HOME`
  - `$XDG_CONFIG_DIRS`
  - `$XDG_DATA_HOME`
  - `$XDG_DATA_DIRS`
- Provides a developer friendly wrapping of the XDG implementation for cache, config, and data. For
  the config, the following is supported:
  - Supports loading of CLI-specific [YAML](http://yaml.org) configuration file.
  - Supports loading and merging of nested/complex configurations.
  - Supports hash representation of configuration.

## Requirements

1. [Ruby 2.6.x](https://www.ruby-lang.org).

## Setup

Type the following to install:

    gem install runcom

Add the following to your Gemfile:

    gem "runcom"

## Usage

This gem provides an embedded XDG implementation along with a developer friendly wrapper
implementation. Both of which are described in detail below.

### XDG

The following describes the embedded XDG implementation. It's worth noting there is a [XDG
Gem](https://github.com/rubyworks/xdg) which also implements the *XDG Base Directory Specification*
but hasn't been updated in ~6 years.

#### Overview

Provides an API that strictly adheres to the *XDG Base Directory Specification*. Usage:

    xdg = Runcom::XDG::Environment.new
    xdg.cache_home # <= Answers computed `$XDG_CACHE_HOME` value.
    xdg.config_home # <= Answers computed `$XDG_CONFIG_HOME` value.
    xdg.config_dirs # <= Answers computed `$XDG_CONFIG_DIRS` value.
    xdg.data_home # <= Answers computed `$XDG_DATA_HOME` value.
    xdg.data_dirs # <= Answers computed `$XDG_DATA_DIRS` value.

The *computed* value, in this case, is either the user-defined value of the key or the default
value, per specification, when the key is not defined or empty. For more on this, scroll down to the
*Variable Defaults* section to learn more.

The `Runcom::XDG::Environment` wraps the following objects which can be used individually if you
don't want to load the entire environment:

    cache = Runcom::XDG::Cache.new
    config = Runcom::XDG::Config.new
    data = Runcom::XDG::Data.new

The `cache`, `config`, and `data` objects share the same API which means you can ask each the
following messages:

- `#home` - Answers the home directory as computed via the `$XDG_*_HOME` key.
- `#directories` - Answers an array directories as computed via the `$XDG_*_DIRS` key.
- `#all` - Answers an array of *all* directories as computed from the combined `$XDG_*_HOME` and
  `$XDG_*_DIRS` values (with `$XDG_*_HOME` prefixed at the start of the array).

#### Variable Defaults

The *XDG Base Directory Specification* defines environment variables and associated default values
when not defined or empty. The following defaults, per specification, are implemented by the
`Runcom::XDG` objects:

- `$XDG_CACHE_HOME="$HOME/.cache"`
- `$XDG_CONFIG_HOME="$HOME/.config"`
- `$XDG_CONFIG_DIRS="/etc/xdg"`
- `$XDG_DATA_HOME="$HOME/.local/share"`
- `$XDG_DATA_DIRS="/usr/local/share/:/usr/share/"`
- `$XDG_RUNTIME_DIR`

The `$XDG_RUNTIME_DIR` deserves special mention as it's not, *currently*, implemented as part of
this gem because it is more user/environment specific. Here is how the `$XDG_RUNTIME_DIR` is meant
to be used should you choose to use it:

- *Must* reference user-specific non-essential runtime files and other file objects (such as
  sockets, named pipes, etc.)
- *Must* be owned by the user with *only* the user having read and write access to it.
- *Must* have a Unix access mode of `0700`.
- *Must* be bound to the user when logging in.
- *Must* be removed when the user logs out.
- *Must* be pointed to the same directory when the user logs in more than once.
- *Must* exist from first login to last logout on the system and not removed in between.
- *Must* not allow files in the directory to survive reboot or a full logout/login cycle.
- *Must* keep the directory on the local file system and not shared with any other file systems.
- *Must* keep the directory fully-featured by the standards of the operating system. Specifically,
  on Unix-like operating systems AF_UNIX sockets, symbolic links, hard links, proper permissions,
  file locking, sparse files, memory mapping, file change notifications, a reliable hard link count
  must be supported, and no restrictions on the file name character set should be imposed. Files in
  this directory *may* be subjected to periodic clean-up. To ensure files are not removed,
  they should have their access time timestamp modified at least once every 6 hours of monotonic
  time or the 'sticky' bit should be set on the file.
- When not set, applications should fall back to a replacement directory with similar capabilities
  and print a warning message. Applications should use this directory for communication and
  synchronization purposes and should not place larger files in it, since it might reside in runtime
  memory and cannot necessarily be swapped out to disk.

#### Variable Behavior

The behavior of most XDG environment variables can be lumped into two categories:

- `$XDG_*_HOME`
- `$XDG_*_DIRS`

Each is described in detail below.

##### `$XDG_*_DIRS`

These variables are used to define a colon (`:`) delimited list of directories. Order is important
as the first directory defined will take precedent over the following directory and so forth. For
example, here is a situation where the `XDG_CONFIG_DIRS` key has a custom value:

    XDG_CONFIG_DIRS="/example/one/.config:/example/two/.settings:/example/three/.configuration"

    # Yields the following, colon delimited, array:
    [
      "/example/one/.config",
      "/example/two/.settings",
      "/example/three/.configuration"
    ]

In the above example, the `"/example/one/.config"` path takes *highest* priority since it was
defined first.

##### `$XDG_*_HOME`

These variables take precidence over the corresponding `$XDG_*_DIRS` environment variables. Using a
modified version of the `$XDG_*_DIRS` example, shown above, we could have the following setup:

    XDG_CONFIG_HOME="/example/priority"
    XDG_CONFIG_DIRS="/example/one/.config:/example/two/.settings"

    # Yields the following, colon delimited, array:
    [
      "/example/priority",
      "/example/one/.config",
      "/example/two/.settings"
    ]

Due to `XDG_CONFIG_HOME` taking precidence over the `XDG_CONFIG_DIRS`, the path with the *highest*
priority in this example is: `"/example/priority"`.

#### Variable Priority

Path precedence is determined in the following order (with the first taking highest priority):

1. `$XDG_*_HOME` - Will be used if defined. Otherwise, falls back to specification default.
1. `$XDG_*_DIRS` - Iterates through directories in order defined (with first taking highest
   priority). Otherwise, falls back to specification default.

### Runcom

Provides wrapper objects around the `XDG` objects which extends and enhances beyond what is found in
the *XDG Base Directory Specification*. This includes preference of local over global configurations
by default as well as other conveniences.

#### Overview

While there isn't an environment convenience object as found in the `XDG` namespace, you can
instantiate each object individually:

    cache = Runcom::Cache.new
    config = Runcom::Config.new
    data = Runcom::Data.new

Each of the above objects share the same basic API:

- `#path` - Answers first *existing* file system path computed by `$XDG_*_HOME` followed
  by each computed `$XDG_*_DIRS` path in order defined.
- `#paths` - Answers all file system paths which is the combined `$XDG_*_HOME` and `$XDG_*_DIRS`
  values in order defined. These paths *may* or *may not* exist on the file system.

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
within your CLI program(s).

An object can be initialized as follows:

    configuration = Runcom::Config.new "example"

The default file name for a configuration is `configuration.yml` but a custom name can be used if
desired:

    configuration = Runcom::Config.new "example", file_name: "example.yml"

Default settings can be initialized as well:

    configuration = Runcom::Config.new "example", defaults: {name: "Example"}

Once a configuration has been initialized, a hash representation can be obtained:

    configuration.to_h

A configuration can be merged with another hash (handy for runtime overrides):

    updated_configuration = configuration.merge {name: "Updated Name"}

A configuration can also be merged with another configuration:

    updated_configuration = configuration.merge Runcom::Config.new("other", defaults: {a: 1})

The computed path of the configuration can be asked for as well:

    configuration.path # "~/.config/example/configuration.yml"

For further details, study the public interface as provided by the
[`Runcom::Config`](lib/runcom/config.rb) object.

### Examples

If you need examples of gems that leverage this gem, see the following:

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
