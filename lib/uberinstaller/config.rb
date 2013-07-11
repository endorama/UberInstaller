# -*- encoding: utf-8 -*-

require 'uberinstaller/version'

module Uberinstaller

  # Shared configuration for Uberinstaller
  module Config
    class << self
      attr_accessor :dry_run, :local_package_manager, :remote_package_manager, :uberdirectory

      attr_reader :app_name, :app_version

      def command_path
        @command_path ||= File.join @uberdirectory, 'cmds'
      end
      def local_pkg_path
        @local_pkg_path ||= File.join @uberdirectory, 'pkgs' 
      end
    end

    # @!attribute [rw] uberdirectory
    #   absolute path to the folder in which the JSON file is located and in which every other installation script must be located
    @uberdirectory = nil
    # @!attribute [r] command_path
    @command_path = nil
    # @!attribute [r] local_pkg_path
    #   absolute path in which local package for the configuration file are found
    @local_pkg_path = nil
    
    # @!attribute [rw] remote_package_manager
    #   the package manager used to install system type packages
    @remote_package_manager = 'Apt'
    # @!attribute [rw] local_package_manager
    #   the package manager used to install local type packages
    @local_package_manager = 'Dpkg'

    # @!attribute [rw] dry_run
    #   prevent real execution of commands enabling a dummy execution for test and debug purposes
    @dry_run = false

    # @!attribute [r] app_name
    #   Application name
    @app_name = "UberInstaller"
    # @!attribute [r] app_version
    #   Application version
    @app_version = VERSION
  end
end
