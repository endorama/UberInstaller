# -*- encoding: utf-8 -*-

require 'uberinstaller/config'
require 'uberinstaller/logger'
require "uberinstaller/package_manager"

module Uberinstaller
  class Ppa
    include Loggable

    def initialize(ppa)
      @ppa = ppa
      # dinamically create instance of the correct PackageManager subclass ( https://www.ruby-forum.com/topic/111997 )
      @exec = ("Uberinstaller::PackageManager::" + Uberinstaller::Config.remote_package_manager).split('::').inject(Object) {|scope,name| scope.const_get(name)}.new
    end

    def is_valid?
      logger.debug 'Validate :ppa'
      @ppa =~ /ppa:[a-z0-9-]+(\/[a-z0-9-]+)?/
    end

    def add
      logger.info 'Adding ppa...'
      @exec.add_repository
    end

    def remove
      logger.info 'Removing ppa...'
      @exec.remove_repository
    end
  end
end
