# Uberinstaller

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'uberinstaller'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install uberinstaller

## Usage

duplicates are overridden!

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

Command before/after:
 - in the right folder: cmds/after/ cmds/before/, so specify only the filename, with extension
 - array of commands
 - a single command in a string

before all => cmds/before/all.sh
after all => cmds/after/all.sh

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
