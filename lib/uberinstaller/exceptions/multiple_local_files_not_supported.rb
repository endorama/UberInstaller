# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When :url for a :type => :git package is not a String
    class MultipleLocalFileNotSupported < Exception
      def initialize(name)
        super "Specify multiple local packages for one package is not supported"
      end
    end
  end
end
