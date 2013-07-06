# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'
require 'uberinstaller/package_manager'

module Uberinstaller
  class Runner
    include Loggable

    # @!attribute [r] packages
    #   the list of packages after configuration file is parsed
    # @!attribute [r] parser
    #   the parser class used to parse configuration file
    # @!attribute [r] platform
    #   the platform on which UberInstaller is running
    # @!attribute [r] unprocessed
    #   check if the execution has already been done
    attr_reader :packages, :parser, :platform, :unprocessed

    # Initialize the Runner class
    #
    # @param file [String] the file name to be used for this execution
    def initialize(file)
      # check if element has already been processed
      @unprocessed = true

      @parser = Parser.new file
      
      @platform = Platform.new

      logger.warn "Platform is not Ubuntu, please report any inconvenient behaviour" unless platform.is_ubuntu?
      
      verify_architecture
      verify_os_version

      @packages = parser.data[:packages]
    end

    def install
      logger.info 'Installing packages...'

      @packages.each do |p|
        pkg_name = p[0].to_s
        pkg = p[1]

        logger.info "Installing #{pkg_name}"

        installer = Installer.new(pkg_name, pkg)

        case pkg[:type]
        when 'system'
          begin 
            installer.install 'system'
          rescue Exception => e
            logger.error e.message

            pkg[:errors] = Array.new # add array to store errors
            pkg[:errors] << e.message
          end
        when 'git'
          begin
            installer.install 'git'
          rescue Exception => e
            logger.error e.message
            
            pkg[:errors] = Array.new # add array to store errors
            pkg[:errors] << e.message
          end
        when 'local'
          begin
            installer.install 'local'
          rescue Exception => e
            logger.error e.message
            
            pkg[:errors] = Array.new # add array to store errors
            pkg[:errors] << e.message
          end
        else
          logger.error "#{pkg_name} :type is not supported"
        end
      end
    end

    # Preprocess all packages performing validation
    def preprocess
      logger.info 'Preprocessing packages...'

      @packages.each do |p|
        pkg_name = p[0].to_s
        pkg = p[1]

        logger.info "Package: #{pkg_name}"
        logger.debug "Package content: #{pkg}"

        # set pkg installation type based on existing key in the package definition
        pkg[:type] = 'system' if pkg.has_key? :system
        pkg[:type] = 'git' if pkg.has_key? :git
        pkg[:type] = 'local' if pkg.has_key? :local

        installer = Installer.new(pkg_name, pkg)

        case pkg[:type]
        when 'system'
          begin 
            installer.preprocess 'system'
          rescue Exception::InvalidPackage, Exception::InvalidPpa => e
            logger.error e.message

            pkg[:skip] = true
            pkg[:errors] = Array.new # add array to store errors
            pkg[:errors] << e.message
          end
        when 'git'
          begin
            installer.preprocess 'git'
          rescue Exception::InvalidFolder, Exception::MissingUrl, Exception::InvalidUrl => e
            logger.error e.message
            
            pkg[:skip] = true
            pkg[:errors] = Array.new # add array to store errors
            pkg[:errors] << e.message
          end
        when 'local'
          begin
            installer.preprocess 'local'
          rescue Exception::MissingLocalPackage, Exception::InvalidLocalPackage => e
            logger.error e.message
            
            pkg[:skip] = true
            pkg[:errors] = Array.new # add array to store errors
            pkg[:errors] << e.message
          end
        else
          logger.error "#{pkg_name} :type is not supported"
        end
      end

      PackageManager.new('remote').update
    end

    # Verify that platform architecture match the one specified in the config file
    #
    # @raise [Exception::WrongArchitecture] if the architecture do not match configuration file
    def verify_architecture
      unless parser.data[:meta][:arch] == 'system'
        logger.debug 'Verifying architecture...'

        unless parser.data[:meta][:arch] == platform.architecture
          raise Exception::WrongArchitecture, 'Installation file requires 32bit architecture' if parser.data[:meta][:arch] == 'i386'
          raise Exception::WrongArchitecture, 'Installation file requires 64bit architecture' if parser.data[:meta][:arch] == 'x86_64'
        else
          logger.info "Architecture match installation file requirements"
        end
      else
        logger.warn "Installation file does not specify a required architecture"
      end
    end

    # Verify that the OS version match the one specified in the config file
    #
    # @raise [Exception::WrongVersion] if the version do not match
    def verify_os_version
      raise Exception::WrongVersion, "Installation file requires a different version. Version required: #{parser.data[:meta][:version]}" unless parser.data[:meta][:version] == platform.lsb[:codename]
    end

    private
      def handle_exception(exception, pkg)
      end
  end
end
