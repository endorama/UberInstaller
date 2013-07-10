# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # Architecture in JSON file different from current OS
    class WrongArchitecture < Exception
      def initialize(arch)
        super "Installation file requires #{arch} architecture"
      end
    end
  end
end
