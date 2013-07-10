# -*- encoding: utf-8 -*-

module Uberinstaller
  module Exception

    # OS version in JSON file different from current OS version ( by codename or number )
    class WrongVersion < Exception
      def initialize(version)
        super "Installation file requires a different version. Version required: #{version}"
      end
    end
  end
end
