# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When package with :type => :git has no :folder
    class InvalidFolder < Exception
      def initialize(name)
        super "#{name} :folder attribute invalid or missing", false
      end
    end
  end
end
