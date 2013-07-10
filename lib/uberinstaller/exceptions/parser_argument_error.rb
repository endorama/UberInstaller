# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # Error when file passed to JSON parser does not exists
    class ParserArgumentError < Exception
      def initialize(file)
        super "Cannot find #{file}, probably a mistyped path?"
      end
    end
  end
end
