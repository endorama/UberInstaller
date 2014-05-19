# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'
require 'uberinstaller/exception'

require 'json'
require 'shellwords'

module Uberinstaller
  class Parser
    include Loggable

    # @!attribute [rw] file
    #   the file to be parsed
    # @!attribute [r] data
    #   an Hash containing data after parsing
    attr_accessor :file
    attr_reader :data

    # Create the parser
    def initialize(file, perform_parse = true)
      if File.exists?(file)
        @file = file
      else
        raise Uberinstaller::Exception::ParserArgumentError, file
      end

      @json = nil
      @data = nil

      run if perform_parse
      self
    end

    def debug
      @json
    end

    def run
      begin
        @json = IO.read(@file)

        @json = _replace_tokens(@json)

        # Comments are stripped out! FUCK YEAH!
        @data = JSON.parse @json, :symbolize_names => true
      rescue JSON::ParserError
        raise Uberinstaller::Exception::JsonParseError, @file
      else
        @data
      end
    end

    private

      # Replace specific tokens with path
      #
      # @param file_content [String] the content of the json file in which the
      #        substitution should take place
      def _replace_tokens(file_content)
        logger.debug "Replacing :cmds with #{Config.command_path.shellescape}"
        file_content.gsub!(':cmds', Config.command_path.shellescape)
        
        logger.debug "Replacing :pkgs with #{Config.local_pkg_path.shellescape}"
        file_content.gsub!(':pkgs', Config.local_pkg_path.shellescape)

        logger.debug "Replacing :json with #{Config.json_path.shellescape}"
        file_content.gsub!(':json', Config.json_path.shellescape)

        file_content
      end

  end
end
