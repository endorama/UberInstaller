# -*- encoding: utf-8 -*-

require 'uberinstaller/package_manager'

module Uberinstaller
  module PackageManager
    class Dpkg < Base

      def set_commands
        @commands[:install] = "dpkg -i"
      end
    end
  end
end
