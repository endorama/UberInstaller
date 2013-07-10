# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When package with :type => :git :url attribute does not respond 200 http status on check
    class InvalidUrl < Exception
      def initialize(name)
        super "#{name} :url seems to not be a valid repo, please check", false
      end
    end
  end
end
