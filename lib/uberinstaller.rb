# -*- encoding: utf-8 -*-

require 'uberinstaller/version'
require 'uberinstaller/config'

require 'uberinstaller/commander'
require 'uberinstaller/exception'
require 'uberinstaller/installer'
require 'uberinstaller/platform'
require 'uberinstaller/package_manager'
require 'uberinstaller/parser'
require 'uberinstaller/runner'


module Uberinstaller
  # Create a new instance of the Runner class in an easy way
  #
  # @param [String] file
  #  the path of the JSON configuration file
  def self.new(file)
    puts "#{Config.app_name} - v#{Config.app_version}"
    Uberinstaller::Runner.new file
  end
end
