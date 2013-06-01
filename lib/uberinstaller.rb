# -*- encoding: utf-8 -*-

require "uberinstaller/version"

require 'uberinstaller/exception'

require 'uberinstaller/package_installer'
require 'uberinstaller/runner'
require 'uberinstaller/platform'
require 'uberinstaller/parser'


module Uberinstaller
  def self.new(file)
    Uberinstaller::Runner.new file
  end
end
