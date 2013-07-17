# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # Error when parsing JSON file
    class JsonFileNotFound < Exception
      def initialize(file)
        super "#{file} can't be found in the correct path"
      end
    end
  end
end
