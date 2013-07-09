# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When package with :type => system has no :pkg specified
    class InvalidPackage < Exception
      def initialize(name)
        super "#{name} has a system installation but invalid :pkg is specified, skipping", false
      end
    end
  end
end
