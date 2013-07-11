# -*- encoding: utf-8 -*-

require 'uberinstaller/config'
require 'uberinstaller/logger'

module Uberinstaller
  module PackageManager

    # Create a new PackageManager instance based on the type
    #
    # @param type [String] the type of package manager to create instance for
    def self.new(type)
      case type
      when 'git'    then package_manager = 'Git'
      when 'local'  then package_manager = Uberinstaller::Config.local_package_manager
      when 'remote' then package_manager = Uberinstaller::Config.remote_package_manager
      end

      ("Uberinstaller::PackageManager::" + package_manager).split('::').inject(Object) {|scope,name| scope.const_get(name)}.new
    end
  end
end

require 'uberinstaller/package_managers/base'
require 'uberinstaller/package_managers/apt'
require 'uberinstaller/package_managers/dpkg'
require 'uberinstaller/package_managers/git'
