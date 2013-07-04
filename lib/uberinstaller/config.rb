# -*- encoding: utf-8 -*-

require 'uberinstaller/version'

module Uberinstaller
  module Config
    class << self
      attr_accessor :local_pkg_path

      attr_reader :app_name, :app_version, :utils_file_path
    end

    @local_pkg_path = Dir.pwd

    @app_name = "UberInstaller"
    @app_version = Uberinstaller::VERSION
  end
end
