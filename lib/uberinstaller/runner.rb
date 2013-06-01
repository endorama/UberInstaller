# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'

module Uberinstaller
  class Runner
    include Loggable

    attr_reader :packages, :parser, :platform, :unprocessed

    def initialize(file)
      @unprocessed = true

      @parser = Uberinstaller::Parser.new file
      
      @platform = Uberinstaller::Platform.new
      logger.warn "Platform is not Ubuntu, please report any inconvenient behaviour" unless platform.is_ubuntu?
      verify_architecture
      verify_os_version
      
      @packages = parser.data[:packages]
    end

    def verify_architecture
      unless parser.data[:meta][:arch] == 'system'
        logger.debug 'Verifying architecture...'

        unless parser.data[:meta][:arch] == platform.architecture
          raise Uberinstaller::Exception::WrongArchitecture, 'Installation file requires 32bit architecture' if parser.data[:meta][:arch] == 'i386'
          raise Uberinstaller::Exception::WrongArchitecture, 'Installation file requires 64bit architecture' if parser.data[:meta][:arch] == 'x86_64'
        else
          logger.info "Architecture match installation file requirements"
        end
      else
        logger.warn "Installation file does not specify a required architecture"
      end
    end

    def verify_os_version
      raise Uberinstaller::Exception::WrongVersion, "Installation file requires a different version. Version required: #{parser.data[:meta][:version]}" unless parser.data[:meta][:version] == platform.lsb[:codename]
    end

    def preprocess
      logger.info 'Preprocessing packages...'

      @packages.each do |p|
        pkg_name = p[0].to_s
        pkg = p[1]

        logger.info "Package: #{pkg_name}"
        logger.debug "Package content: #{pkg}"
        
        pkg[:type] = 'system' unless pkg.has_key? :type

        case pkg[:type]
        when 'system'
          begin 
            Uberinstaller::PackageInstaller.new(pkg_name, pkg).preprocess 'system'
          rescue Uberinstaller::Exception::InvalidPackage, Uberinstaller::Exception::InvalidPpa => e
            logger.error e.message
          end
        when 'git'
        when 'local'
        else
          logger.error "#{pkg_name} :type is not supported"
        end
      end
    end


  end
end
