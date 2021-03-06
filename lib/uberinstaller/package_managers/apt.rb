# -*- encoding: utf-8 -*-

require 'uberinstaller/package_manager'

module Uberinstaller
  module PackageManager
    # Apt-Get Package manager
    class Apt < Base

      def set_commands
        @commands[:add_repository] = "apt-add-repository -y" 
        @commands[:install] = "DEBIAN_FRONTEND=gnome apt-get install -y" 
        @commands[:update] = "apt-get update" 
        @commands[:upgrade] = "apt-get upgrade" 
      end
    end
  end
end
