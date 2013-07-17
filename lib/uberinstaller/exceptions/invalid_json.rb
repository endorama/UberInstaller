# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When package with :type => :git :url attribute does not respond 200 http status on check
    class InvalidJson < Exception
      def initialize(name)
        super "#{name} :json seems to not be a valid string, please check", false
      end
    end
  end
end
