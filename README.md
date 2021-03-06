# Uberinstaller

Uberinstaller is a ruby gem that make easy to install system packages from a JSON configuration file.
Thinked for Ubuntu, can handle pre and post installation commands, repositories and PPA, package installation from system repositories, git repositories or local files.

Has support for different Package Managers as the one in use now can be modified and extended as needed.

## Installation

Add this line to your application's Gemfile:

    gem 'uberinstaller'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uberinstaller

Also, you need to have `sudo` installed and working on your machine to execute the uberinstaller executable and for every command launched from uberinstaller.

## Usage

duplicates are overridden!
order is respected!

Architecture verification:
 - system => leave to the system to handle architecture package version resolution
 - i386 => can be run only on 32 bit systems
 - x86_64 => can be run only on 64 bit systems

Version verification:
 - codename of OS ( precise on ubuntu )

Installation type:
 - system
 - git
 - local
 - json ( no extension )

Command before/after:
 - in the right folder: cmds/after/ cmds/before/, so specify only the filename, with extension
 - array of commands

before all => cmds/before/all.sh
after all => cmds/after/all.sh

Blocking package configuration as Debconf in Debian system must be properly avoided ( APT Package Manager use gnome DEBIAN_FRONTEND to avoid apt-get hangs)

## Folder structure

package
├── cmds
├── log
├── pkgs
└── package.json

## Variables substitution

You can use some variables in package.json:
 - `:cmds`: path to package/cmds folder
 - `:pgks`: path to package/pkgs folder
 - `:json`: path to package/package.json file

## Docs

http://rubydoc.info/docs/yard/file/docs/GettingStarted.md
http://rubydoc.info/docs/yard/file/docs/Tags.md

http://gorails.com/setup/ubuntu

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
