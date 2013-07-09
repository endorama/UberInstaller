# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # When a package as an unknown command ( is not a string nor an array )
    class CommandNotProcessable < Exception
      def initialize(name, type)
        super "#{name}'s #{type} command is not proccessable, as it is of unknown type"
      end
    end
  end
end
