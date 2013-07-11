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

    # When :pkg for a :type => :local package is not a String
    class MultipleLocalFileNotSupported < Exception; end
  end
end

require 'uberinstaller/exceptions/command_not_processable'
require 'uberinstaller/exceptions/invalid_folder'
require 'uberinstaller/exceptions/invalid_local_package'
require 'uberinstaller/exceptions/invalid_package'
require 'uberinstaller/exceptions/invalid_ppa'
require 'uberinstaller/exceptions/invalid_url'
require 'uberinstaller/exceptions/json_parse_error'
require 'uberinstaller/exceptions/missing_local_package'
require 'uberinstaller/exceptions/multiple_local_files_not_supported'
require 'uberinstaller/exceptions/multiple_repositories_not_supported'
require 'uberinstaller/exceptions/missing_url'
require 'uberinstaller/exceptions/parser_argument_error'
require 'uberinstaller/exceptions/wrong_architecture'
require 'uberinstaller/exceptions/wrong_version'
