# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When package with :type => :git has no :url
    class MissingUrl < Exception
      def initialize(name)
        super "#{name} :url attribute is missing", false
      end
    end
  end
end
