# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'

module Uberinstaller
  class Ppa
    include Loggable

    def initialize(ppa)
      @ppa = ppa
      @exec = "apt-add-repository --yes '#{@ppa}'"
    end

    def is_valid?
      logger.debug 'Validate :ppa'
      @ppa =~ /ppa:[a-z0-9-]+(\/[a-z0-9-]+)?/
    end

    def debug
      @exec
    end

    def add
      logger.info 'Adding ppa...'
      # `#{@exec}`
    end

    def remove
      # `#{@exec} --remove`
    end
  end
end
