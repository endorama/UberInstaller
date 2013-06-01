# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'

module Uberinstaller
  module Exception
    class Exception < StandardError
      include Loggable

      attr :parent
      
      def initialize(parent, print = true)
        @parent = parent
        logger.fatal parent if print
        super parent
      end
    end

    # Error when parsing JSON file
    class ParseError < Exception; end
    # Error when file passed to parser does not exists
    class ParserArgumentError < Exception; end
    # Architecture in JSON file different from current OS
    class WrongArchitecture < Exception; end
    # OS version in JSON file different from current OS version ( by codename or number )
    class WrongVersion < Exception; end
    # When package with :type => system has no :pkg specified
    class InvalidPackage < Exception; end
    # When package with :type => system has an invalid :ppa
    class InvalidPpa < Exception; end
  end
end
