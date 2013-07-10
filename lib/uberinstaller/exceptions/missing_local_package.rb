# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When package with :type => :local has no :pkg attribute
    class MissingLocalPackage < Exception
      def initialize(name)
        super "#{name} :pkg seems not to be a valid local package", false
      end
    end
  end
end
