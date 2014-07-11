# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'

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
      logger.debug Config.command_path
      logger.debug Config.local_pkg_path
      logger.debug Config.json_path
      logger.info "Processing JSON file: #{file}"
      
      # check if element has already been processed
      @unprocessed = true

      @parser = Parser.new file
      
      @platform = Platform.new

      logger.warn "Platform is not Ubuntu, please report any inconvenient behaviour" unless platform.is_ubuntu?
      
      verify_architecture
      verify_os_version

      # This dummy commander is used to launch before all and after all scripts
      @global_commander = Commander.new("Dummy package", { :cmd => { :after => "all.sh", :before => "all.sh" }})

      @packages = parser.data[:packages]

      get_nested_json
    end

    def install
      logger.info 'Installing packages...'

      @packages.each do |p|
        pkg_name = p[0].to_s
        pkg = p[1]

        installer = Installer.new(pkg_name, pkg)
        commander = Commander.new(pkg_name, pkg)

        logger.info "Installing #{pkg_name}"

        commander.before

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
          rescue Exception::MultipleLocalFilesNotSupported => e
            logger.error e.message
            
            pkg[:errors] = Array.new # add array to store errors
            pkg[:errors] << e.message
          end
        else
          logger.error "#{pkg_name} :type is not supported"
        end

        commander.after
      end

      logger.info 'Executing after all commands...'
      @global_commander.after
    end

    # Preprocess all packages performing validation
    def preprocess
      logger.info 'Executing before all commands...'
      @global_commander.before

      logger.info 'Preprocessing packages...'
      @packages.each do |p|
        pkg_name = p[0].to_s
        pkg = p[1]

        logger.info "Package: #{pkg_name}"
        logger.debug "Package content: #{pkg}"

        # set pkg installation type based on existing key in the package definition
        pkg[:type] = get_package_type pkg

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
      if parser.data[:meta][:arch]
        unless parser.data[:meta][:arch] == 'system'
          logger.debug 'Verifying architecture...'

          unless parser.data[:meta][:arch] == platform.architecture
            raise Exception::WrongArchitecture, parser.data[:meta][:arch]
          else
            logger.info "Architecture match installation file requirements"
          end
        end
      else
        logger.warn "Installation file does not specify a required architecture"
      end
    end

    # Verify that the OS version match the one specified in the config file
    #
    # @raise [Exception::WrongVersion] if the version do not match
    def verify_os_version
      raise Exception::WrongVersion, parser.data[:meta][:version] unless parser.data[:meta][:version] == platform.lsb[:codename]
    end

    private
      def get_nested_json
        nested_packages = Hash.new

        @packages.each do |p|
          pkg_name = p[0].to_s
          pkg = p[1]

          if pkg.has_key? :json
            installer = Installer.new(pkg_name, pkg)

            begin
              installer.preprocess 'json'
            rescue Exception::JsonFileNotFound, Exception::InvalidJson => e
              logger.error e.message

              pkg[:skip] = true
              pkg[:errors] = Array.new # add array to store errors
              pkg[:errors] << e.message
            else
              file = File.join Config.json_path, pkg[:json] + '.json'
              parser = Parser.new(file)
              data = parser.data[:packages].each { |p| p[1][:type] = get_package_type p[1] }
              nested_packages.merge! data

              @packages.delete(pkg_name.to_sym)
            end
          end
        end

        @packages.merge! nested_packages
      end

      def get_package_type(pkg)
        return 'system' if pkg.has_key? :system
        return 'git' if pkg.has_key? :git
        return 'local' if pkg.has_key? :local
      end
  end
end
