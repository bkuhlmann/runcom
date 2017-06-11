# Runcom

[![Gem Version](https://badge.fury.io/rb/runcom.svg)](http://badge.fury.io/rb/runcom)
[![Code Climate GPA](https://codeclimate.com/github/bkuhlmann/runcom.svg)](https://codeclimate.com/github/bkuhlmann/runcom)
[![Code Climate Coverage](https://codeclimate.com/github/bkuhlmann/runcom/coverage.svg)](https://codeclimate.com/github/bkuhlmann/runcom)
[![Gemnasium Status](https://gemnasium.com/bkuhlmann/runcom.svg)](https://gemnasium.com/bkuhlmann/runcom)
[![Circle CI Status](https://circleci.com/gh/bkuhlmann/runcom.svg?style=svg)](https://circleci.com/gh/bkuhlmann/runcom)
[![Patreon](https://img.shields.io/badge/patreon-donate-brightgreen.svg)](https://www.patreon.com/bkuhlmann)

A [run command manager](https://en.wikipedia.org/wiki/Run_commands) for command line interfaces
(CLI). It manages/resolves local or global resource (i.e. `.<program>rc`) settings for CLIs.

<!-- Tocer[start]: Auto-generated, don't remove. -->

# Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
- [Usage](#usage)
- [Tests](#tests)
- [Versioning](#versioning)
- [Code of Conduct](#code-of-conduct)
- [Contributions](#contributions)
- [License](#license)
- [History](#history)
- [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

# Features

- Loads local or global YAML resource configurations.
- Automatically detects and resolves local or global resource configurations.
- Provides support for merging of nested/complex configurations.
- Supports hash representation of configuration.

# Requirements

0. [Ruby 2.4.x](https://www.ruby-lang.org)

# Setup

For a secure install, type the following (recommended):

    gem cert --add <(curl --location --silent https://www.alchemists.io/gem-public.pem)
    gem install runcom --trust-policy MediumSecurity

NOTE: A HighSecurity trust policy would be best but MediumSecurity enables signed gem verification
while allowing the installation of unsigned dependencies since they are beyond the scope of this
gem.

For an insecure install, type the following (not recommended):

    gem install runcom

Add the following to your Gemfile:

    gem "runcom"

# Usage

Start by leveraging the `Runcom::Configuration` object as follows:

    configuration = Runcom::Configuration.new file_name: ".examplerc"

There is optional support for default settings too:

    configuration = Runcom::Configuration.new file_name: ".examplerc", defaults: {name: "Example"}

Default settings will be overwitten if matching local or global setting keys are detected. Order of
precedence is determined as follows:

0. Local (i.e. `<current working directory>/.examplerc`)
0. Global (i.e. `$HOME/.examplerc`)
0. Defaults (i.e. `{}` unless specified upon initialization).

If multiple settings are detected, only the first one found will be used.

For further details, study the public interface as provided by the
[`Runcom::Configuration`](lib/runcom/configuration.rb) object.

# Tests

To test, run:

    bundle exec rake

# Versioning

Read [Semantic Versioning](http://semver.org) for details. Briefly, it means:

- Major (X.y.z) - Incremented for any backwards incompatible public API changes.
- Minor (x.Y.z) - Incremented for new, backwards compatible, public API enhancements/fixes.
- Patch (x.y.Z) - Incremented for small, backwards compatible, bug fixes.

# Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By
participating in this project you agree to abide by its terms.

# Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

# License

Copyright (c) 2016 [Alchemists](https://www.alchemists.io).
Read [LICENSE](LICENSE.md) for details.

# History

Read [CHANGES](CHANGES.md) for details.
Built with [Gemsmith](https://github.com/bkuhlmann/gemsmith).

# Credits

Developed by [Brooke Kuhlmann](https://www.alchemists.io) at
[Alchemists](https://www.alchemists.io).
