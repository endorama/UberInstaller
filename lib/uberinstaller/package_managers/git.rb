# -*- encoding: utf-8 -*-

require 'uberinstaller/package_manager'

module Uberinstaller
  module PackageManager
    class Git < Base

      def set_commands
        @commands[:install] = "git clone" 
      end
    end
  end
end
