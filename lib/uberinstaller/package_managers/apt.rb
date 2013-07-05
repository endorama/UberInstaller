# -*- encoding: utf-8 -*-

require 'uberinstaller/package_manager'

module Uberinstaller
  module PackageManager
    class Apt < Base

      def initialize
        super

        @commands[:add_repository] = "apt-add-repository -y" 
        @commands[:install] = "apt-get install -y" 
        @commands[:update] = "apt-get update" 
        @commands[:upgrade] = "apt-get upgrade" 
      end
    end
  end
end
