# -*- encoding: utf-8 -*-

require 'uberinstaller/version'

module Uberinstaller

  # Shared configuration for Uberinstaller
  module Config
    class << self
      attr_accessor :local_package_manager, :remote_package_manager

      attr_reader :app_name, :app_version

      attr_writer :local_pkg_path
      def local_pkg_path
        File.join @local_pkg_path, 'pkgs' if @local_pkg_path
      end
    end

    # @!attribute [rw] local_pkg_path
    #   absolute path in which local package for the configuration file are found
    @local_pkg_path = nil
    # @!attribute [rw] remote_package_manager
    #   the package manager used to install system type packages
    @remote_package_manager = 'Apt'
    # @!attribute [rw] local_package_manager
    #   the package manager used to install local type packages
    @local_package_manager = 'Dpkg'


    # @!attribute [r] app_name
    #   Application name
    @app_name = "UberInstaller"
    # @!attribute [r] app_version
    #   Application version
    @app_version = VERSION
  end
end
