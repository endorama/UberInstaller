# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When package with :type => system has an invalid :ppa
    class InvalidPpa < Exception
      def initialize(name)
        super "#{name} has an invalid ppa, skipping", false
      end
    end
  end
end
