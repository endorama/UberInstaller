# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'
require 'uberinstaller/config'
require 'uberinstaller/exception'
require 'uberinstaller/package_manager'

require 'octokit'

module Uberinstaller
  class Installer
    include Loggable

    # Initialize the class
    #
    # @param pkg_name [String] the name of the package
    # @param pkg_body [Hash] an Hash containing the parsed information for the package
    def initialize(pkg_name, pkg_body)
      @name = pkg_name
      @body = pkg_body
      
      # an Hash containing private processing info for the class
      @meta = Hash.new
      @meta[:installable] = true

      if @body.has_key? :skip and @body[:skip]
        logger.warn "#{@name} has :skip option active, skipping "
      end
    end

    # Return if the package is installable
    #
    # @return [bool] true if the package can be installed, false otherwise
    def installable?
      @body[:skip] ? false : true
    end

    # Perform package validation based upon installation type
    #
    # @param type [String] the installation type
    def validate(type)
      case type
      when 'system' then validate_system
      when 'git' then validate_git
      when 'local' then validate_local
      end
    end

    # Perform package installation based upon installation type, only if installable? is true
    #
    # @param type [String] the installation type
    def install(type)
      return unless installable?

      case type
      when 'system' then install_system
      when 'git' then install_git
      when 'local' then install_local
      end
    end

    # Perform package preprocessing based upon installation type, only if installable? is true
    #
    # @param type [String] the installation type
    def preprocess(type)
      return unless installable?

      case type
      when 'system' then preprocess_system
      when 'git' then preprocess_git
      when 'local' then preprocess_local
      end
    end

    private

      def install_system
        logger.debug 'Sytem type installation'
      end

      # Preprocess a system type package.
      #
      # Launch validation and on success add the ppa to the system, if any
      def preprocess_system
        logger.debug 'Sytem type preprocess'

        package_manager = ("Uberinstaller::PackageManager::" + Uberinstaller::Config.remote_package_manager).split('::').inject(Object) {|scope,name| scope.const_get(name)}.new

        begin
          validate 'system'
        rescue Exception => e
          @body[:skip] = true
          raise e
        else
          package_manager.add_repository @body[:system][:ppa] if @body[:system].has_key? :ppa
        end
      end

      # Validate a system type package
      #
      # Check if package has a :pkg key and if if is valid; check if package has a :ppa key and perform validation on the ppa string.
      #
      # @raise [Uberinstaller::Exception::InvalidPackage] if the package is not valid
      # @raise [Uberinstaller::Exception::InvalidPpa] if the ppa is not valid
      def validate_system
        logger.debug 'Sytem type validation'

        if !@body[:system].has_key? :pkg or !valid_pkg?
          raise Uberinstaller::Exception::InvalidPackage.new "#{@name} has a system installation but invalid :pkg is specified, skipping", false
        end

        if @body[:system].has_key? :ppa
          raise Uberinstaller::Exception::InvalidPpa.new "#{@name} has an invalid ppa, skipping", false unless valid_ppa? @body[:system][:ppa]
        end
      end

      def install_git
      end

      # Preprocess a git type package
      #
      # Launch validation
      def preprocess_git
        logger.debug 'Git type preprocess'
        begin
          validate 'git'
        rescue Exception => e
          @body[:skip] = true
          raise e
        end
      end

      # Validate a git type package
      #
      # Check for :folder and :url keys and perform validation on :url
      #
      # @raise [Uberinstaller::Exception::InvalidFolder] if no :folder is specified
      # @raise [Uberinstaller::Exception::MissingUrl] if no :url is specified
      # @raise [Uberinstaller::Exception::Invalid] if :url is not a valid Github repository
      def validate_git
        logger.debug 'Git type validation'

        if !@body[:git].has_key? :folder
          raise Uberinstaller::Exception::InvalidFolder.new "#{@name}  :folder attribute invalid or missing", false
        end

        if !@body[:git].has_key? :url
          raise Uberinstaller::Exception::MissingUrl.new "#{@name} :url attribute is missing", false
        else
          repo_url = @body[:git][:url].split('github.com')[1].split('.git')[0]
          repo_url[0] = ''

          begin
            Octokit.repo repo_url
          rescue
            raise Uberinstaller::Exception::InvalidUrl.new "#{@name} :url seems to not be a valid repo, please check", false
          end
        end
      end

      def install_local
      end

      # Preprocess a local type package
      #
      # Launch validation
      def preprocess_local
        logger.debug 'Local type preprocess'
        begin
          validate 'local'
        rescue Exception => e
          @body[:skip] = true
          raise e
        end
      end

      # Validate local type package
      #
      # @raise [Uberinstaller::Exception::MissingLocalPackage] if the local package has no :pkg
      # @raise [Uberinstaller::Exception::InvalidLocalPackage] if the local package has an invalid :pkg
      def validate_local
        logger.debug 'Local type validation'

        if !@body[:local].has_key? :pkg
          raise Uberinstaller::Exception::MissingLocalPackage.new "#{@name} :pkg seems not to be a valid local package", false
        else
          raise Uberinstaller::Exception::InvalidLocalPackage.new "#{@name} :pkg seems not to be a valid local package", false if !valid_local_pkg?
        end
      end

      ###

      # Check if the string is a valid repository
      #
      # TODO: chack for repo, not only ppa
      # @param repository [String] a valid string repository/PPA URL
      #
      # @return [bool] true if the string is a valid repository, false otherwise
      def valid_repository?(repository)
        logger.debug 'Validate repository'
        repository =~ /ppa:[a-z0-9-]+(\/[a-z0-9-]+)?/
      end

      # Check if a system package is valid
      #
      # A package is valid when the :pkg key is a non-empty string or a non-empty array
      #
      # @return [bool] true if the package is valid, false otherwise
      def valid_pkg?
        logger.debug 'Validate :pkg'
        !(@body[:system][:pkg].empty? or @body[:system][:pkg].any? { |a| a.empty? })
      end

      # Check if a local package is valid
      #
      # A local package is valid when :pkg key is a string corresponding to a existing file path
      #
      # @return [bool] true if the package is validw, false otherwise
      def valid_local_pkg?
        logger.debug 'Validate local pkg'
        File.file?(File.join Uberinstaller::Config.local_pkg_path, 'pkgs', @body[:local][:pkg])
      end
  end
end
