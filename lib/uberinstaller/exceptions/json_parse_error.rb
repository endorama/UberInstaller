# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # Error when parsing JSON file
    class JsonParseError < Exception
      def initialize(file)
        super "#{file} cannot be parsed as is not valid JSON"
      end
    end
  end
end
