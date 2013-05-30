# -*- encoding: utf-8 -*-

require 'uberinstaller/logger'

require 'hash_keyword_args'

module Uberinstaller
  class Platform
    include Loggable

    attr_reader :lsb, :uname
    
    # => get platform, detect ubuntu, detect ubuntu version, save lsb params
    # 
    # => params:
    # =>   opts Hash
    # =>     :lsb => the file containing LSB information
    def initialize(opts = {})
      @opts = opts.keyword_args(:lsb => '/etc/lsb-release')
      
      @lsb = nil
      @uname = nil
      
      get_lsb_informations
      # get_arch_informations
    end

    def is_ubuntu?
      @lsb[:id] == 'Ubuntu' if @lsb[:id]
    end

    def is_64bit?
      @uname[:machine] == 'x86_64' if @uname[:machine]
    end

    private
      def get_arch_informations
        @uname ||= Hash.new
        IO.popen 'uname -m' do |io| @uname[:machine] = io.read.strip end
        IO.popen 'uname -n' do |io| @uname[:host] = io.read.strip end
        IO.popen 'uname -srv' do |io| @uname[:kernel] = io.read.strip end
      end

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

      def get_lsb_value(string)
        string.split('=')[1].strip
      end
  end
end
