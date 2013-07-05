# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'

require 'hash_keyword_args'

module Uberinstaller
  # http://stackoverflow.com/questions/170956/how-can-i-find-which-operating-system-my-ruby-program-is-running-on
  class Platform
    include Loggable

    # @!attribute [r] architecture
    #   OS architecture information
    # @!attribute [r] lsb
    #   LSB module information
    # @!attribute [r] uname
    #   `uname` calls results
    attr_reader :architecture, :lsb, :uname
    
    # Get platform, detect ubuntu, detect ubuntu version, save lsb params
    # 
    # @param opts [Hash]
    #  :lsb => the file containing LSB information
    def initialize(opts = {})
      @opts = opts.keyword_args(:lsb => '/etc/lsb-release')
      
      @lsb = nil
      @uname = nil
      
      get_lsb_informations
      get_arch_informations

      @architecture = @uname[:machine]
    end

    # Check if platform is Ubuntu
    def is_ubuntu?
      return @lsb[:id] == 'Ubuntu' if @lsb[:id]
      logger.fatal 'lsb is not set, impossible to get OS information'
      false
    end

    # Reverse of is_ubuntu?
    def is_not_ubuntu?
      !is_ubuntu?
    end

    # Reverse of is_64bit?
    def is_32bit?
      !is_64bit?
    end

    # Check if system is running 64 bit OS
    def is_64bit?
      return @uname[:machine] == 'x86_64' if @uname[:machine]
      logger.fatal 'uname is not set, impossible to get machine information'
      false
    end

    private
      # Detect OS architecture information
      #
      # Using a call to `uname` try to detect architecture informations.
      # `uname` must be available on the system
      def get_arch_informations
        @uname ||= Hash.new
        IO.popen 'uname -m' do |io| @uname[:machine] = io.read.strip end
        IO.popen 'uname -n' do |io| @uname[:host] = io.read.strip end
        IO.popen 'uname -srv' do |io| @uname[:kernel] = io.read.strip end
      end

      # Get OS information from LSB
      #
      # LSB must be aavailable on the system
      def get_lsb_informations
        # http://stackoverflow.com/a/1236075/715002
        IO.popen "cat #{@opts.lsb}" do |io|
          io.each do |line|
            unless line.include? 'cat:' # check for error
              @lsb ||= Hash.new

              if line.include? 'DISTRIB_ID'
                @lsb[:id] = get_lsb_value line
              elsif line.include? 'DISTRIB_RELEASE'
                @lsb[:release] = get_lsb_value line
              elsif line.include? 'DISTRIB_CODENAME'
                @lsb[:codename] = get_lsb_value line
              elsif line.include? 'DISTRIB_DESCRIPTION'
                @lsb[:description] = get_lsb_value line
              end
            else
              logger.fatal "Platform has no #{@opts.lsb}, so it is not supported"
            end
          end
        end
      end

      # Handy method to retrieve values from LSB pairs
      def get_lsb_value(string)
        string.split('=')[1].strip
      end
  end
end
