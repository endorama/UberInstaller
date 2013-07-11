# -*- encoding: utf-8 -*-

require 'uberinstaller/package_manager'

module Uberinstaller
  module PackageManager
    # Git package manager ( a little bit of a hack really )
    class Git < Base

      def set_commands
        @commands[:install] = "git clone" 
      end
    end
  end
end
