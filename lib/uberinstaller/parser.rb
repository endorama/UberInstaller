# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'
require 'uberinstaller/exception'

require 'json'

module Uberinstaller
  class Parser
    include Loggable

    attr_accessor :file
    attr_reader :data

    def initialize(file, perform_parse = true)
      if File.exists?(file)
        @file = file
      else
        logger.fatal "Cannot find #{file}, probably a mistyped path?"
        raise Uberinstaller::Exception::ParserArgumentError, ':file does not exists'
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
        # Comments are stripped out! FUCK YEAH!
        @data = JSON.parse @json, :symbolize_names => true
      rescue Exception => e  
        raise Uberinstaller::Exception::ParseError, e
      else
        
        @data
      end
    end

  end
end
