# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'
require 'uberinstaller/exception'
require 'uberinstaller/ppa'

module Uberinstaller
  class PackageInstaller
    include Loggable

    def initialize(pkg_name, pkg_body)
      @name = pkg_name
      @body = pkg_body
      
      @meta = Hash.new
      @meta[:installable] = true

      if @body.has_key? :skip and @body[:skip]
        logger.info "#{@name} has :skip option active, skipping "
        @meta[:installable] = false
      end

    end

    def installable?
      @meta[:installable]
    end

    def validate(type)
      case type
      when 'system' then validate_system
      when 'git' then validate_git
      when 'local' then validate_local
      end
    end

    def install(type)
      return unless installable?

      case type
      when 'system' then install_system
      when 'git' then install_git
      when 'local' then install_local
      end
    end

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
      end

      def preprocess_system
        logger.debug 'Sytem type preprocess'
        begin
          validate 'system'
        rescue Exception => e
          @body[:skip] = true
          raise e
        else
          logger.debug @meta[:ppa].debug
          @meta[:ppa].add
        end
      end

      def validate_system
        logger.debug 'Sytem type validation'

        if !@body[:system].has_key? :pkg or !valid_pkg?
          raise Uberinstaller::Exception::InvalidPackage.new "#{@name} has a system installation but invalid :pkg is specified, skipping", false
        end

        if @body[:system].has_key? :ppa
          @meta[:ppa] = Uberinstaller::Ppa.new @body[:system][:ppa]
          raise Uberinstaller::Exception::InvalidPpa.new "#{@name} has an invalid ppa, skipping", false unless @meta[:ppa].is_valid?
        end
      end

      def install_git
      end

      def preprocess_git
        logger.debug 'Git type preprocess'
        begin
          validate 'git'
        rescue Exception => e
          @body[:skip] = true
          raise e
        else
          # logger.debug @meta[:ppa].debug
          # @meta[:ppa].add
        end
      end

      def validate_git
        logger.debug 'Git type validation'
      end

      def install_local
      end

      ###

      def valid_pkg?
        logger.debug 'Validate :pkg'
        !(@body[:system][:pkg].empty? or @body[:system][:pkg].any? { |a| a.empty? })
      end
  end
end
