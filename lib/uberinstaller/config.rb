# -*- encoding: utf-8 -*-

require 'uberinstaller/version'

module Uberinstaller

  # Shared configuration for Uberinstaller
  module Config
    class << self
      attr_accessor :local_pkg_path

      attr_reader :app_name, :app_version, :utils_file_path
    end

    # @!attribute [rw] local_pkg_path
    #   absolute path in which local package for the configuration file are found
    @local_pkg_path = nil

    # @!attribute [r] app_name
    #   Application name
    @app_name = "UberInstaller"
    # @!attribute [r] app_version
    #   Application version
    @app_version = VERSION
  end
end
